# == Schema Information
#
# Table name: packages
#
#  id                    :integer          not null, primary key
#  aasm_state            :string(255)
#  ship_code             :string(255)
#  shipped_at            :datetime
#  created_at            :datetime
#  updated_at            :datetime
#  package_no            :string(255)
#  logistics_supplier_id :integer
#

class Package < ActiveRecord::Base
  include Logcraft::Trackable
  include AASM

  include Redis::Objects
  hash_key :yto_express

  has_one :shipping_info, as: :billable, dependent: :destroy
  has_many :print_items
  has_many :order_items, -> { group('order_items.id') }, through: :print_items
  has_many :orders, -> { group('orders.id') }, through: :order_items
  has_many :waybill_routes

  belongs_to :logistics_supplier

  delegate :name, :phone, :address, :city, :state, :zip_code, :country,
           :country_code, :shipping_way, :email, to: :shipping_info,
                                                 prefix: true, allow_nil: true
  delegate :name, to: :logistics_supplier, prefix: true, allow_nil: true

  class << self
    def create_package_with_print_items(options)
      ActiveRecord::Base.transaction do
        package = Package.create
        package.associate_print_items(options)
        package.clone_shipping_info!
        package.set_package_no
        package.toboard!
      end
    end
  end

  aasm do
    state :packaged, initial: true
    state :onboard
    state :shipping

    event :toboard do
      transitions from: :packaged, to: :onboard
      after do
        print_items.each(&:toboard!)
        orders.each(&:package_strategy)
      end
    end

    event :ship do
      transitions from: :onboard, to: :shipping
      after do
        print_items.each(&:ship!)
        orders.each(&:ship_strategy)
        create_ship_activity
      end
    end
  end

  def associate_print_items(options)
    if options[:print_items].present?
      PrintItem.where(id: options[:print_items].keys).update_all(package_id: id)
    elsif options[:orders].present?
      Order.where(id: options[:orders].keys).find_each do |order|
        order.print_items.update_all(package_id: id)
      end
    elsif options[:print_item_ids].present?
      PrintItem.where(id: options[:print_item_ids]).update_all(package_id: id)
    else
      fail ParametersInvalidError
    end
  end

  def order_items_quantity
    order_items.reduce(0) { |sum, order_item| sum += order_item.quantity }
  end

  def print_items_count
    print_items.size
  end

  def split_order?
    orders.size == 1
  end

  def split_order
    orders.first if split_order?
  end

  def first_order
    orders.first
  end

  def clone_shipping_info!
    create_shipping_info!(first_order.shipping_info.clone_shipping_info_attributes)
  end

  def set_package_no
    PackageNoService.new(self).assign_package_no
  end

  def subtotal(currency = 'CNY')
    print_items.reduce(0) do |sum, print_item|
      sum += print_item.order_item.original_price_in_currency(currency)
    end
  end

  private

  def create_ship_activity
    create_activity(:shipped,
                    print_item_ids: print_items.pluck(:id),
                    order_item_ids: order_items.pluck(:id),
                    order_ids: orders.pluck(:id))
  end
end
