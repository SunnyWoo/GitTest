# == Schema Information
#
# Table name: order_items
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  itemable_id      :integer
#  itemable_type    :string(255)
#  quantity         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  timestamp_no     :integer
#  print_at         :datetime
#  aasm_state       :string(255)
#  pdf              :string(255)
#  prices           :json
#  original_prices  :json
#  discount         :decimal(8, 2)
#  remote_id        :integer
#  delivered        :boolean          default(FALSE)
#  deliver_complete :boolean          default(FALSE)
#  remote_info      :json
#  selling_prices   :json
#

require 'net/ftp'
require 'open-uri'
class OrderItem < ActiveRecord::Base
  include Logcraft::Trackable
  has_paper_trail
  serialize :remote_info, Hashie::Mash.pg_json_serializer

  attr_accessor :discount_info

  belongs_to :order
  belongs_to :itemable, -> { try(:with_deleted) || all }, polymorphic: true

  has_many :print_items, dependent: :destroy
  has_many :packages, -> { group('packages.id') }, through: :print_items
  has_many :notes, as: :noteable, dependent: :destroy
  has_many :adjustments, -> { order(created_at: :desc) }, as: :adjustable, dependent: :destroy

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :itemable, presence: true

  delegate :cover_image, :print_image, :order_image, :product, :uuid, :name,
           to: :itemable, prefix: true, allow_nil: true
  delegate :id, :uuid, to: :order, prefix: true, allow_nil: false
  delegate :external_production?, to: :itemable_product, allow_nil: true

  scope :delivery, -> { where(delivered: true) }
  scope :not_delivery, -> { where(delivered: false) }
  scope :unpackaged, -> { joins(:print_items).merge(PrintItem.unpackaged).group('order_items.id') }

  UNRANSACKABLE_ATTRIBUTES = %w(itemable_type created_at updated_at print_at pdf).freeze

  before_create :store_prices
  after_commit :replace_by_archived_item, on: :create

  def self.ransackable_attributes(_auth_object = nil)
    (column_names - UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys
  end

  include AASM

  aasm do
    state :pending, initial: true
    state :printed
    state :delivering
    state :received
    state :sublimated
    state :qualified
    state :onboard
    state :shipping

    event :print do
      transitions from: :pending, to: :printed
      after do
        order.update! work_state: :working
      end
    end

    event :deliver do
      transitions from: :pending, to: :delivering
      after do
        delivered!
      end
    end

    event :receive do
      transitions from: :delivering, to: :received
      before { self.deliver_complete = true }
      after { check_deliver_complete! }
    end

    event :sublimate do
      transitions from: [:pending, :printed], to: :sublimated
      after do
        check_deliver_complete!
      end
    end

    event :check do
      transitions from: [:received, :sublimated], to: :qualified
    end

    event :toboard do
      transitions from: [:received, :qualified], to: :onboard
      after do
        create_toboard_activity
      end
    end

    event :ship do
      transitions from: :onboard, to: :shipping
      after do
        create_ship_activity
      end
    end

    event :revert_qualified do
      transitions from: [:onboard, :shipping], to: :qualified
    end

    event :revert_received do
      transitions from: [:onboard, :shipping], to: :received
    end

    event :reprint do
      transitions to: :pending, unless: :need_deliver?
      after do
        order.order_items.not_delivery.each do |order_item|
          order_item.update! aasm_state: :pending
          order_item.print_items.each { |print_item| print_item.update! aasm_state: :pending }
        end
        order.update! work_state: :ongoing, aasm_state: :paid
      end
    end
  end

  # 特價
  def price_in_currency(target_currency = currency)
    price = prices.try(:[], target_currency) ||
            itemable.try(:price_in_currency, target_currency)
    price || 0
  end

  # replaced by selling price in the future
  def adjusted_price_in_currency(target_currency = currency)
    price_in_currency(target_currency) + adjustment_value_per_item
  end

  def adjusted_subtotal(target_currency = currency)
    price_in_currency(target_currency) * quantity + adjustments_value
  end

  # 原價
  def original_price_in_currency(target_currency = currency)
    price = original_prices.try(:[], target_currency) ||
            itemable.try(:original_price_in_currency, target_currency)
    price || 0
  end

  def generate_pdf
    PdfService.delay.generate(id)
  end

  def clone_to_print_items
    print_items.delete_all
    quantity.times { print_items.create(product: itemable.product) }
    print_items.each(&:deliver!) if need_deliver?
  end

  def need_deliver?
    itemable.product.remote?
  end

  # 儲存當下單價 (不計入數量)
  def store_prices
    self.prices = itemable.prices
    self.original_prices = itemable.original_prices
    self.selling_prices = itemable.promotion_special_price.to_h
  end

  def replace_by_archived_item
    CreateArchiveItemWorker.perform_async(id)
  end

  def china_archive_attributes
    {
      item_id: id,
      quantity: quantity,
      itemable_type: itemable_type,
      work: itemable.china_archive_attributes
    }
  end

  def delivered!
    update_attribute(:delivered, true)
  end

  def real_status
    (delivered? && !external_production?) ? remote_info['aasm_state'] || 'pending' : aasm_state
  end

  def print_image_exist?
    itemable.print_image.present?
  end

  # 优惠信息
  # 优惠组合序号： coupon设定的优惠组合中第几组; 0,1,2...
  # {优惠组合序号 => 优惠个数}
  def discount_info
    @discount_info ||= {}
  end

  def order_items_all_shipping?
    aasm_state = order.order_items.pluck(:aasm_state)
    aasm_state.all? { |state| state == 'shipping' }
  end

  def adjustments_value(_base_price_type = Order::DEFAULT_PRICE_TYPE)
    adjustments.select(&:pricing?).sum(&:value)
  end

  def adjustment_value_per_item
    adjustments_value / quantity
  end

  def apply_with_available_promotion
    return unless itemable.respond_to?(:build_promotion_adjustment)
    itemable.build_promotion_adjustment(self)
  end

  def weight
    itemable_product.weight.to_f * quantity
  end

  def product_factory_name
    itemable_product.factory.try(:name)
  end

  def adjustable_name
    "#{self.class.name}: #{itemable.name}"
  end

  # 取得每個 itemable 扣掉 折扣後的 銷售價格
  # 帶入 to_currency 可以轉換成不同 currency 的金額
  def per_itemable_price(to_currency = nil)
    currency = order.currency
    per_price = ((Price.new(prices[currency]).value * quantity - discount.to_f) / quantity).round(4)
    per_price = Price.new(per_price, currency)[to_currency] if to_currency.present?
    per_price
  end

  def subtotal
    selling_price * quantity
  end

  def selling_price
    @selling_price ||= if persisted?
                         Price.new(selling_prices || prices, currency)
                       else
                         itemable.promotion_special_price.with_currency!(currency)
                       end
  end

  def shipping_fee
    order_actual_shipping_fee = order.shipping_fee.to_f - order.shipping_fee_discount.to_f
    order_actual_shipping_fee / order.order_items.count * quantity
  end

  def itemable_name
    itemable_type.in?(%w(Work ArchivedWork)) ? 'Customization' : 'Designer'
  end

  private

  def check_deliver_complete!
    return unless order.delivered?
    aasm_state = order.order_items.pluck(:aasm_state)
    order.deliver_complete! if aasm_state.all? { |state| %w(received sublimated).include?(state) }
  end

  def create_ship_activity
    create_activity(:ship, package_id: packages.last.try(:id))
  end

  def create_toboard_activity
    create_activity(:toboard, package_id: packages.last.try(:id))
  end

  def currency
    order.currency || Region.default_currency
  end
end
