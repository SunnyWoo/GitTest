class CartSession
  include CartRedis
  attr_accessor :user_id, :cart, :coupon, :store_id

  def initialize(args = {})
    @user_id = args.delete(:user_id)
    @store_id = args.delete(:store_id)
    @controller = args.delete(:controller)
  end

  def items
    cart[:items] ||= {}
  end

  def add_items(work_gid, quantity = nil)
    quantity ||= 1
    work_gid = work_gid.to_s.to_sym
    if items[work_gid].present?
      items[work_gid] = items[work_gid].to_i + quantity.to_i
    else
      items[work_gid] = quantity
    end
  end

  def update_items(work_gid, quantity = nil)
    work_gid = work_gid.to_s.to_sym
    if items[work_gid].present? && (1..10).cover?(quantity.to_i)
      items[work_gid] = quantity.to_i
    end
    cart.merge!(items: items)
  end

  def delete_items(work_gid)
    work_gid = work_gid.to_s.to_sym
    if items[work_gid].present?
      items.delete(work_gid)
      @cart.delete(:coupon_code)
      cart.merge!(items: items)
    end
  end

  def valid_coupon_code?(coupon_code, user)
    coupon = Coupon.find_by(code: coupon_code)
    @coupon = coupon
    order = build_tmp_order
    coupon.present? &&
      coupon.can_use?(user, order) &&
      coupon.pass_condition?(order.price_calculator, order.currency)
  end

  def apply_coupon_code(coupon_code)
    cart.merge!(coupon_code: coupon_code)
  end

  def clear_coupon_code
    cart.delete(:coupon_code)
  end

  def reload_order(order)
    cart[:order_no] = order.order_no
    cart[:payment] = order.payment
    cart[:currency] = order.currency
    cart[:items] = {}
    order.order_items.each do |order_item|
      add_items(order_item.itemable.to_gid, order_item.quantity)
    end
    %w(shipping_info billing_info).each do |str|
      cart[str] = reload_billing_profile(order.send(str))
    end
  end

  def reload_billing_profile(obj)
    {
      shipping_way: obj.shipping_way,
      country_code: obj.country_code,
      name: obj.name,
      phone: obj.phone,
      address: obj.address,
      city: obj.city,
      state: obj.state,
      zip_code: obj.zip_code,
      country: obj.country,
      email: obj.email
    }
  end

  def update_check_out(params)
    [:payment, :currency, :message, :order_info].each do |param|
      cart[param] = params[param] if params[param].present?
    end
    if params[:shipping_way].present?
      cart[:shipping_info][:shipping_way] = params[:shipping_way]
    end
    [:shipping_info, :billing_info].each do |address_info|
      next unless params[address_info].present?
      params[address_info].each do |key, val|
        cart[address_info][key] = val
      end
    end
  end

  def normalized_items
    items.map do |work_id, quantity|
      if work_id =~ URI.regexp
        # work_id is a gid
        { 'work_gid' => work_id.to_s, 'quantity' => quantity }
      else
        # work_id is uuid (for backward compatibility)
        work = Work.find_by(uuid: work_id.to_s)
        { 'work_gid' => work.to_gid.to_s, 'quantity' => quantity }
      end
    end
  end

  def build_tmp_order
    params = cart.slice(:payment,
                        :coupon_code,
                        :billing_info,
                        :shipping_info,
                        :message,
                        :order_info,
                        :bdevent_id)
    params[:items] = normalized_items if cart[:items].size > 0
    params[:currency] = current_currency_code
    params.merge!(store_info) if store_id.present?

    @order = Order.new
    @order.build_tmp_order(params)
    @order
  end

  def build_order
    fail CartIsEmptyError if cart[:items].empty?
    @order = cart[:order_no].present? ? Order.find_by(order_no: cart[:order_no]) : Order.new
    @order.user = @user_id.present? ? User.find(@user_id) : User.new_guest
    @order.build_order(build_order_params)
    @order
  end

  def render_item_quantity(work_gid)
    items[work_gid.to_s] || 1
  end

  def clean(order = nil)
    if order.present? && @controller.session
      @controller.session[:guest_user_order_no] = order.order_no if order.user.guest?
    end
    @cart = default_cart
    @controller.session[:cart] = nil
    save
  end

  def cart
    @cart ||= Hashie::Mash.new(redis_get || @controller.session[:cart] || default_cart)
  end

  def save
    if @user_id.present?
      redis_set(cart)
    else
      @controller.session[:cart] = cart
    end
  end

  def item_sum
    cart[:items].empty? ? 0 : cart[:items].values.map(&:to_i).sum
  end

  def build_order_params
    args = {
      currency: current_currency_code,
      uuid: UUIDTools::UUID.timestamp_create.to_s,
      coupon: cart[:coupon_code],
      order_items: normalized_items,
      platform: @controller.try(:os_type),
      ip: @controller.try(:remote_ip),
      user_agent: @controller.try(:request).try(:user_agent),
      locale: I18n.locale,
      app_id: current_application
    }.merge(cart.slice(
      :payment, :billing_info, :shipping_info, :message, :order_info, :bdevent_id
    )).symbolize_keys
    args.merge!(store_info) if store_id.present?
    args
  end

  def current_application
    @controller.current_application.try(:id) if @controller.respond_to?(:current_application)
  end

  def default_cart
    params = {
      order_no: '',
      items: {},
      payment: 'paypal',
      shipping_info: { shipping_way: 'standard' },
      billing_info: {},
      currency: current_currency_code
    }
    params[:shipping_info][:country_code] = 'TW' if Region.global?
    Hashie::Mash.new(params)
  end

  def current_currency_code
    @controller.current_currency_code || 'USD'
  end

  def store_info
    store = Store.find_by(id: store_id)
    store.present? ? { source: 'shop', channel: store_id } : {}
  end
end
