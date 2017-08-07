# == Schema Information
#
# Table name: print_items
#
#  id              :integer          not null, primary key
#  order_item_id   :integer
#  timestamp_no    :integer
#  aasm_state      :string(255)
#  print_at        :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  model_id        :integer
#  prepare_at      :datetime
#  sublimated_at   :datetime
#  onboard_at      :datetime
#  package_id      :integer
#  qualified_at    :datetime
#  shipped_at      :datetime
#  enable_schedule :boolean          default(TRUE)
#

class PrintItem < ActiveRecord::Base
  include Logcraft::Trackable
  has_one :temp_shelf

  belongs_to :package
  belongs_to :order_item
  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id

  has_many :print_histories

  validates :product, presence: true

  before_create :set_prepare_at
  after_create :create_print_history
  after_update :create_state_changed_activity

  include AASM

  delegate :key, :name, :width, :height, to: :product, prefix: true
  delegate :external_production?, to: :product
  delegate :serial, :description, to: :temp_shelf, prefix: true, allow_nil: true

  scope :with_states, ->(*states) { where(aasm_state: states) }
  scope :unpackaged, -> { where(package_id: nil) }

  aasm do
    state :pending, initial: true
    state :uploading
    state :printed
    state :delivering
    state :received
    state :sublimated
    state :qualified
    state :onboard
    state :shipping

    event :upload do
      before do
        give_timestamp_no
      end
      transitions from: :pending, to: :uploading
    end

    event :print do
      transitions from: :uploading, to: :printed
      after do
        check_state_printed
      end
    end

    event :deliver do
      transitions from: :pending, to: :delivering, if: :need_deliver?
    end

    event :external_production do
      transitions from: :uploading, to: :delivering
      after do
        check_state_delivering
      end
    end

    event :receive do
      transitions from: :delivering, to: :received
      after do
        check_state_received
      end
    end

    event :sublimate do
      before do
        self.sublimated_at = Time.zone.now
      end
      transitions from: :printed, to: :sublimated
      after do
        check_state_sublimated
      end
    end

    event :check do
      before do
        self.qualified_at = Time.zone.now
      end
      transitions from: [:received, :sublimated], to: :qualified
      after do
        check_state_qualified
      end
    end

    event :toboard do
      before do
        self.onboard_at = Time.zone.now
      end
      transitions from: [:received, :qualified], to: :onboard
      after do
        check_state_onboard
      end
    end

    event :ship do
      before do
        self.shipped_at = Time.zone.now
      end
      transitions from: :onboard, to: :shipping
      after do
        check_state_shipping
      end
    end

    event :revert_qualified do
      before do
        self.onboard_at = nil
      end
      transitions from: [:onboard, :shipping], to: :qualified
    end

    event :revert_received do
      before do
        self.onboard_at = nil
      end
      transitions from: [:onboard, :shipping], to: :received
    end

    event :reprint do
      before do |print_history_params|
        self.sublimated_at = nil
        self.qualified_at = nil
        self.onboard_at = nil
        self.shipped_at = nil
        # 只有客服退货重印才需要更新进入印刷工作站时间
        if print_history_params && print_history_params[:print_type] == 'customer_service_retprint'
          self.prepare_at = Time.zone.now
        end
      end
      transitions to: :pending, unless: :need_deliver?
      after do |print_history_params|
        order_item.update! aasm_state: :pending
        order.update! work_state: :ongoing, aasm_state: :paid, packaging_state: :package_ongoing, shipping_state: :shipping_ongoing
        create_print_history(print_history_params)
        temp_shelf.delete if temp_shelf
      end
    end
  end

  delegate :order, to: :order_item

  def give_timestamp_no
    if pending?
      self.timestamp_no = Timestamp.today_timestamp_no
      self.print_at = Time.zone.now
      save!
    else
      errors.add(:base, 'Print item state is not pending')
    end
  end

  def print_image
    order_item.itemable.print_image
  end

  def order_image
    order_item.itemable.order_image
  end

  def back_image_path
    ImageService::MiniMagick::BackImageGenerator.new(self).execute
  end

  def output_files
    if order_item.itemable.class.to_s == 'ArchivedStandardizedWork'
      order_item.itemable.output_files.where.not(key: 'print-image').map(&:file_url)
    else
      []
    end
  end

  def price_in_currency(currency)
    order_item.itemable.price_in_currency(currency)
  end

  def not_sublimated?
    aasm_state.in? %w(pending uploading printed)
  end

  def reprint_logs
    order.activities.where("key = ? and extra_info->>'print_item_id' = ?", 'reprint', id.to_s)
  end

  # 是否重印过
  def is_reprint?
    print_histories.where.not(print_type: :print).present?
  end

  # 重印是否完成
  def reprinted?
    is_reprint? && !not_sublimated?
  end

  %w(print_image output_files white_image).each do |file_name|
    # XXX: Deprecated. 當新方法都沒問題後可以移除這裡
    define_method "get_#{file_name}" do
      urls = case file_name
             when 'print_image' || 'image'
               [print_image.escaped_url]
             when 'output_files'
               output_files
             when 'white_image'
               [print_image.escaped_url(:gray)]
             else
               [file_name]
             end

      files = []

      urls.each do |url|
        file_extension = File.extname(URI.parse(url).path)
        file_name = if file_name == 'output_files'
                      "tmp/#{order_item.order.order_no}-#{id}#{file_extension}"
                    elsif file_name == 'white_image'
                      "tmp/#{timestamp_no}-#{id}-white#{file_extension}"
                    else
                      "tmp/#{timestamp_no}-#{id}#{file_extension}"
                    end
        File.open(file_name, 'wb') { |file| file.write open(url).read }
        files << file_name
      end

      files
    end
  end

  alias_method :get_image, :get_print_image

  class << self
    def upload_multi_file_to_printer(print_item_ids, file_gateway_id)
      print_items = PrintItem.find(print_item_ids)
      file_gateway = FileGateway.find(file_gateway_id)
      file_names = []
      print_items.each do |print_item|
        file_names = file_names + print_item.get_image + print_item.get_ouput_files
        file_names += print_item.get_white_image if print_item.product.enable_white?
        file_names += [print_item.back_image_path] if print_item.product.enable_back_image?
      end
      status = file_gateway.batch_upload(file_names, nil, memo: "print_item_id: #{print_item_ids.join(',')}")
      begin
        print_items.each(&:print!) if status == true
      rescue => e
        print_items.each { |pi| pi.create_activity(:print_error, message: "Error:#{e}") }
      end
    end

    def get_image(item)
      file_extension = File.extname(URI.parse(item.print_image.url).path)
      uuid = UUIDTools::UUID.timestamp_create.to_s
      file_name = "temp-#{uuid}#{file_extension}"
      File.open(file_name, 'wb') do |file|
        file.write open(item.print_image.url).read
      end
      file_name
    end
  end

  def disable_schedule
    update_column(:enable_schedule, false)
  end

  private

  def need_deliver?
    product.remote?
  end

  def check_state_printed
    all_states = order_item.print_items.pluck(:aasm_state)
    order_item.print! if all_states.all? { |state| state.in? %w(printed sublimated qualified onboard shipping) }
  end

  def check_state_sublimated
    all_states = order_item.print_items.pluck(:aasm_state)
    order_item.sublimate! if all_states.all? { |state| state.in? %w(sublimated qualified onboard shipping) }
  end

  def check_state_delivering
    all_states = order_item.print_items.pluck(:aasm_state)
    order_item.deliver! if all_states.all? { |state| state.in? %w(delivering received onboard shipping) }
  end

  def check_state_received
    all_states = order_item.print_items.pluck(:aasm_state)
    order_item.receive! if all_states.all? { |state| state.in? %w(received onboard shipping) }
  end

  def check_state_qualified
    all_states = order_item.print_items.pluck(:aasm_state)
    if all_states.all? { |state| state.in? %w(qualified onboard shipping) }
      order_item.receive if order_item.may_receive?
      order_item.check!
    end
  end

  def check_state_onboard
    all_states = order_item.print_items.pluck(:aasm_state)
    order_item.toboard! if all_states.all? { |state| state.in? %w(onboard shipping) }
  end

  def check_state_shipping
    all_states = order_item.print_items.pluck(:aasm_state)
    order_item.ship! if all_states.all? { |state| state == 'shipping' }
  end

  def create_state_changed_activity
    if aasm_state_changed?
      create_activity(:state_changed, state_change: aasm_state_change)
      update_print_history
    end
  end

  def update_print_history
    print_history = print_histories.last
    return if print_history.blank?
    print_history.timestamp_no = timestamp_no
    print_history.print_at = print_at
    print_history.sublimated_at = sublimated_at
    print_history.qualified_at = qualified_at
    print_history.onboard_at = onboard_at
    print_history.shipped_at = shipped_at
    print_history.save
  end

  def create_print_history(print_history_params = {})
    print_history_params = { print_type: 'print' } if print_history_params.blank?
    print_histories.create(prepare_at: prepare_at,
                           print_type: print_history_params[:print_type],
                           reason: print_history_params[:reason])
  end

  def set_prepare_at
    self.prepare_at = Time.zone.now
  end
end
