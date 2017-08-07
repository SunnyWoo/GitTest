class Campaign::WaterpackageOrder
  include ActiveModel::Model
  include ActiveModel::Validations
  attr_accessor :order, :payload, :product_key

  PRODUCT_KEYS = %w(waterpackage_350ml waterpackage_350ml_6pcs).freeze

  validate :validate_payload
  validates_inclusion_of :product_key, in: PRODUCT_KEYS, message: "Product key must in #{PRODUCT_KEYS}"

  def initialize(order, params)
    @payload = params.delete(:payload) || []
    @payload = [@payload] if @payload.is_a?(Hash)
    @product_key = params.delete(:product_key)
    @order = order
    @order.build_order(params, allowed_empty_items: true)
  end

  def save
    if valid?
      ActiveRecord::Base.transaction do
        product = ProductModel.find_by!(key: product_key)
        work = Work.create!(name: 'waterpackage', product: product, user: order.user)
        order.order_items.build(itemable: work, quantity: 1)

        order.coupon = Coupon.find_by_code(schema['coupon_code']) if schema['coupon_code'].present?
        order.calculate_price!
        CreateWaterpackageWorker.perform_async(work.id, payload)
        Campaign::WaterpackageWorkService.logger.info "OrderID=#{order.id}: #{payload}"
      end
    else
      false
    end
  end

  private

  def validate_payload
    payload.each do |obj|
      unless obj.key?('name') && obj.key?('school_name')
        errors.add(:playload, 'keys must in (name, school_name)')
      end
    end
  end

  def schema
    @schema ||= Hash(Campaign::WaterpackageWorkService::SCHEMA['products'][product_key])
  end
end
