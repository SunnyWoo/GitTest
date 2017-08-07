class Pricing::OrderBuilder
  attr_reader :order

  DEFAULT_PAYMENT_METHOD = 'paypal'.freeze

  def initialize(order, params, options = {})
    @order = order
    @options = options
    order.user = options[:user] if options[:user]
    order.billing_info || order.build_billing_info
    order.shipping_info || order.build_shipping_info
    @data = normalize_params(params)
  end

  def perform!(opts = {})
    @order.transaction do
      @order.order_items.destroy_all if @order.order_items.count > 0

      @order.attributes = @data.slice(
        :uuid, :currency, :payment,
        :platform, :ip, :user_agent, :locale, :application_id,
        :message, :source, :channel, :order_info, :bdevent_id
      )

      @order.billing_info.attributes = @data[:billing_info] if @data[:billing_info]
      @order.shipping_info.attributes = @data[:shipping_info] if @data[:shipping_info]

      check_and_assign_coupon!
      assign_items!

      @order.pricing = Pricing::OrderPriceCalculator.new(@order).process!
      @order.save! if opts[:save]
      @order
    end
  end

  private

  def check_and_assign_coupon!
    coupon_code = @data[:coupon]
    order.coupon = nil if order.persisted? && coupon_code.blank?

    Coupon.find_valid(coupon_code, order.user) if coupon_code.present? && validate_coupon?

    coupon = coupon_code && Coupon.find_coupon(coupon_code)

    return unless coupon
    return order.coupon = coupon if temp?
    raise InvalidCouponError unless coupon.can_use?(order.user, order)

    order.coupon = coupon
  end

  def assign_items!
    return if Array(@data[:items]).empty?
    @data[:items].each do |item|
      work = fuzzy_find_by_item!(item)
      raise WorkNotFoundError if work.nil?
      @order.order_items.build(itemable: work, quantity: item['quantity'], remote_id: item['remote_id'])
    end
  end

  def normalize_params(params)
    order_items = Array(params[:order_items] || params[:items])

    raise ApplicationError, "order_items can\'t be blank" unless order_items.any? || allowed_empty_items?

    data = {}.merge(params.slice(
      :uuid, :currency, :payment,
      :platform, :ip, :user_agent, :locale, :application_id,
      :message, :source, :channel, :bdevent_id
    )).symbolize_keys

    data[:order_info] = params[:order_info] if params[:order_info]
    data[:payment] = params[:payment_method] if params[:payment_method]
    data[:coupon] = params[:coupon]          if params[:coupon]
    data[:coupon] = params[:coupon_code]     if params[:coupon_code] # Cart Version
    data[:application_id] = params[:app_id]  if params[:app_id]
    data[:payment] ||= DEFAULT_PAYMENT_METHOD

    data[:items] = order_items.map do |order_item|
      case order_item[:type]
      when 'create', 'shop' # from orders#price API
        order_item.slice(:product_model_key, :work_uuid, :quantity)
      else # from cart or orders#update API
        order_item
      end
    end

    shipping_attrs = params[:shipping_info] || params[:billing_info]
    billing_attrs = params[:billing_info]

    if shipping_attrs
      data[:shipping_info] = BillingProfile.normalize_address_params(shipping_attrs)
    end

    if billing_attrs
      data[:billing_info] = BillingProfile.normalize_address_params(billing_attrs)
    end

    data
  end

  def fuzzy_find_by_item!(item)
    case
    when item['work_gid'] then GlobalID::Locator.locate(item['work_gid'])
    when item['work_uuid'] then Work.find_by(uuid: item['work_uuid']) || StandardizedWork.find_by(uuid: item['work_uuid'])
    when item['work_id'] then Work.find_by(uuid: item['work_id'])
    when item['product_model_key'] then Work.new(product: ProductModel.find_by(key: item['product_model_key']))
    end
  end

  # For temporarily building order by cart, it could
  # 1. Accept empty items
  # 2. Accept coupon which is not applicable yet
  def temp?
    @options[:temp].to_b
  end

  def allowed_empty_items?
    temp? || @options[:allowed_empty_items]
  end

  # Forcibly do validation as long as coupon code has provided
  def validate_coupon?
    @options[:validate_coupon].to_b
  end
end
