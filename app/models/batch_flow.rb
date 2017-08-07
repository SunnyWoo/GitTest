# == Schema Information
#
# Table name: batch_flows
#
#  id                :integer          not null, primary key
#  aasm_state        :string(255)
#  factory_id        :integer
#  product_model_ids :integer          default([]), is an Array
#  print_item_ids    :integer          default([]), is an Array
#  batch_no          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  deadline          :datetime
#  locale            :string(255)
#

class BatchFlow < ActiveRecord::Base
  include Logcraft::Trackable
  include RedisCacheable

  belongs_to :factory
  has_many :attachments, class_name: BatchFlowAttachment.to_s, dependent: :destroy
  validates :factory, :deadline, :product_model_ids, presence: true
  validates :batch_no, uniqueness: true, presence: true
  validates :locale, presence: true, inclusion: { in: Factory::LOCALES }

  before_validation :generate_batch_no, on: :create
  after_update :create_state_changed_activity

  BATCH_DELAY_DAYS = 8

  value :job_id
  set :job_logs, marshal: true

  include AASM
  aasm do
    state :pending, initial: true
    state :initialized
    state :processing
    state :completed
    state :canceled
    state :failed

    event :initial do
      before { retrieve_print_item_ids }

      transitions from: :pending, to: :initialized
      after do
        print_items.each(&:upload!)
      end
    end

    event :start do
      transitions from: :initialized, to: :processing
      after { process_in_background }
    end

    event :finish do
      before do
        print_items.each(&:external_production!)
      end
      transitions from: :processing, to: :completed
      after do
        clear_job_id
        enqueue_send_file_uploaded_notice_mail_job
      end
    end

    event :failure do
      transitions from: :processing, to: :failed
      after do |failure_params|
        if failure_params[:error]
          error = failure_params[:error]
          job_logs << { timestamp: Time.zone.now, message: error.message, backtrace: error.backtrace[0, 20].join("\n") }
        end
      end
    end

    event :cancel do
      before do
        print_items.each(&:reprint!)
      end
      transitions from: [:initialized, :failed], to: :canceled
    end
  end

  def product_models
    ProductModel.where(id: product_model_ids)
  end

  def print_items
    PrintItem.where(id: print_item_ids)
  end

  def order_items
    OrderItem.where(id: print_items.pluck(:order_item_id))
  end

  def number
    batch_no
  end

  def number_with_source
    "#{Region.china? ? 'CN' : 'TW'}#{number}"
  end

  def send_mail(type:)
    case type.to_sym
    when :file_uploaded then FactoryMailer.file_uploaded(id, factory_id).deliver
    else
      fail "no such type: #{type}"
    end
  end

  # This method was called with stateless, could be used without considering state
  def process!
    service = BatchFlow::FileDumpService.new(self)
    dumped_directory = service.perform!
    BatchFlowFileSmuggleService.new(self, dumped_directory, 'document', 'image').execute
  ensure
    service.clean
  end

  def process_in_background
    self.job_id = BatchFlowProcessWorker.perform_async(id)
  end

  private

  def generate_batch_no
    self.batch_no = Time.zone.now.strftime("%Y%m%d-%H%M")
  end

  def retrieve_print_item_ids
    self.print_item_ids = product_models.map do |product|
      PrintItem.pending.ransack(
        order_item_order_aasm_state_eq: 'paid',
        model_id_eq: product.id,
        aasm_state: 'pending'
      ).result.pluck(:id)
    end.flatten
  end

  # We skip this validation until it really processed by separated factories
  # def validates_factory_match_product_model
  #   if !(product_model_ids.map{ |i| i.to_i } - factory.product_models.pluck(:id)).empty?
  #     errors.add(:product_model_ids, I18n.t('errors.batch_flow_invalid_product_model_not_match_factory'))
  #   end
  # end

  def create_state_changed_activity
    create_activity(:state_changed, state_change: aasm_state_change) if aasm_state_changed? && !aasm_state_was.nil?
  end

  def enqueue_send_file_uploaded_notice_mail_job
    FactoryReminder.perform_async(id, type: :file_uploaded)
    create_activity(:send_file_uploaded_mail)
  end

  def clear_job_id
    self.job_id = nil
  end
end
