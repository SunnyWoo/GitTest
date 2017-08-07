class Api::V1::My::OrdersController < ApiController
  before_action :authenticate_required!
  before_action :validate_build_order, only: [:create]
  skip_before_action :verify_authenticity_token, only: 'pay_result'
  before_action :set_locale
  # User Order list
  #
  # Url : /api/my/orders
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/my/orders
  #
  # Return Example
  #   [
  #     {
  #       "uuid": "ccbe45fa-5a62-11e4-9109-3c15c2d24fd8",
  #       "price": 0,
  #       "currency": "USD",
  #       "status": "Pending",
  #       "coupon": null,
  #       "order_no": "14AN000192",
  #       "billing_info": {
  #         "address": "065 Windler UnionApt. 044",
  #         "city": "Anastacioville",
  #         "name": "Araceli Schulist",
  #         "phone": "738-227-8166",
  #         "state": "Washington",
  #         "zip_code": "90296",
  #         "country": "United States",
  #         "created_at": "2014-10-23T11:15:12.050+08:00",
  #         "updated_at": "2014-10-23T11:15:12.050+08:00",
  #         "country_code": "US",
  #         "shipping_way": "standard",
  #         "email": "marty@yahoo.com"
  #       },
  #       "order_items": [
  #         {
  #           "quantity": 1,
  #           "work_id": "ccf00360-5a62-11e4-9109-3c15c2d24fd8",
  #           "work_uuid": "ccf00360-5a62-11e4-9109-3c15c2d24fd8"
  #         }
  #       ]
  #     }
  #   ]
  #
  # @return [JSON] status 200
  def index
    @orders = current_user.orders
    render json: @orders, root: false
    fresh_when(etag: @orders)
  end

  # Show user order
  #
  # Url : /api/my/orders/:uuid
  #
  # RESTful : GET
  #
  # Get Example
  #   /api/my/orders/769faa56-5a62-11e4-a0a3-3c15c2d24fd8
  #
  # Return Example
  #   {
  #     "uuid": "769faa56-5a62-11e4-a0a3-3c15c2d24fd8",
  #     "price": 0,
  #     "currency": "USD",
  #     "status": "Pending",
  #     "coupon": null,
  #     "order_no": "14AN000198",
  #     "billing_info": {
  #       "address": "345 Dixie BrookSuite 992",
  #       "city": "Greenholtbury",
  #       "name": "Nicolas Hudson",
  #       "phone": "1-513-852-4815 x9235",
  #       "state": "Iowa",
  #       "zip_code": "51936",
  #       "country": "United States",
  #       "created_at": "2014-10-23T11:12:47.558+08:00",
  #       "updated_at": "2014-10-23T11:12:47.558+08:00",
  #       "country_code": "US",
  #       "shipping_way": "standard",
  #       "email": "eloisa@gmail.com"
  #     },
  #     "order_items": [
  #       {
  #         "quantity": 1,
  #         "work_id": "76cfd05a-5a62-11e4-a0a3-3c15c2d24fd8",
  #         "work_uuid": "76cfd05a-5a62-11e4-a0a3-3c15c2d24fd8"
  #       }
  #     ]
  #   }
  #
  # @param request uuid [Strign] Order uuid
  #
  # @return [JSON] status 200
  def show
    @order = current_user.orders.find_by(uuid: params[:uuid])
    if @order.present?
      render json: @order, root: false
      fresh_when(etag: @order, last_modified: @order.updated_at)
    else
      render json: { message: 'Not found' }, status: :not_found
    end
  end

  # User create order
  #
  # Url : /api/my/orders
  #
  # RESTful : POST
  #
  # Post Example
  #   post /api/my/orders
  #   {
  #     auth_token: user auth_token,
  #     uuid: "f8090090-5a55-11e4-955d-3c15c2d24fd8",
  #     currency: 'USD',
  #     coupon: '807A7C',
  #     payment_method: 'paypal',
  #     billing_info: {
  #       name: "Christelle Franecki DVM",
  #       phone: "1-075-681-6427",
  #       address: "3030 Brenden Springs",
  #       city: "Devinside",
  #       state: "Virginia",
  #       zip_code: "82930-2086",
  #       country: "United States",
  #       country_code: 'US',
  #       shipping_way: 'standard',
  #       email: "avery@deckow.us"
  #     },shipping_info: {
  #       name: "Christelle Franecki DVM",
  #       phone: "1-075-681-6427",
  #       address: "3030 Brenden Springs",
  #       city: "Devinside",
  #       state: "Virginia",
  #       zip_code: "82930-2086",
  #       country: "United States",
  #       country_code: 'US',
  #       shipping_way: 'standard',
  #       email: "avery@deckow.us"
  #     },
  #     order_items: [
  #       work_uuid: "f812a280-5a55-11e4-955d-3c15c2d24fd8",
  #       quantity: 1
  #     ]
  #   }
  #
  # Return Example
  #   {
  #     "uuid": "2601a404-5a63-11e4-86e8-3c15c2d24fd8",
  #     "price": 94.9,
  #     "currency": "USD",
  #     "status": "pending",
  #     "payment": "paypal",
  #     "payment_method": "paypal",
  #     "coupon": {
  #       "id": 1,
  #       "title": "hello coupon",
  #       "code": "1C74E2",
  #       "expired_at": "2015-10-23",
  #       "is_used": true,
  #       "created_at": "2014-10-23T11:17:41.403+08:00",
  #       "updated_at": "2014-10-23T11:17:41.403+08:00",
  #       "event": false
  #     },
  #     "order_no": "14AN000219US",
  #     "order_price": {
  #       "sub_total": 99.9,
  #       "coupon": 5,
  #       "shipping_fee": 0,
  #       "total": 94.9
  #     },
  #     "billing_info": {
  #       "address": "022 Reggie Dale",
  #       "city": "South Sierraville",
  #       "name": "Guiseppe Gleichner",
  #       "phone": "1-192-783-1497 x3675",
  #       "state": "Delaware",
  #       "zip_code": "52298-8125",
  #       "country": "United States",
  #       "created_at": "2014-10-23T11:17:42.196+08:00",
  #       "updated_at": "2014-10-23T11:17:42.196+08:00",
  #       "country_code": "US",
  #       "shipping_way": "standard",
  #       "email": "armando@ebertframi.com"
  #     },
  #     "shipping_info": {
  #       "address": "41527 Mateo Light",
  #       "city": "Mercedesview",
  #       "name": "Giovani Stehr",
  #       "phone": "424.215.3869 x109",
  #       "state": "Tennessee",
  #       "zip_code": "92430-7745",
  #       "country": "United States",
  #       "created_at": "2014-10-23T11:17:42.202+08:00",
  #       "updated_at": "2014-10-23T11:17:42.202+08:00",
  #       "country_code": "US",
  #       "shipping_way": "standard",
  #       "email": "raymundo.gottlieb@dicki.us"
  #     },
  #     "order_items": [
  #       {
  #         "quantity": 1,
  #         "work_id": "260a7d68-5a63-11e4-86e8-3c15c2d24fd8",
  #         "work_uuid": "260a7d68-5a63-11e4-86e8-3c15c2d24fd8"
  #       }
  #     ]
  #   }
  #
  #  @param request auth_token [String] user auth_token
  #  @param request uuid [String] order uuid
  #  @param request currency [String] currency
  #  @param coupon [String] Coupon code
  #  @param request payment_method [String] Payment like 'paypal'
  #  @param request billing_info: {
  #    name: name
  #    phone: Phone
  #    address: Address
  #    city: City
  #    state: State
  #    zip_code: Zip code
  #    country: Country
  #    country_code: Country Code
  #    shipping_way: Shipping Way
  #    email: E-mail
  #  }
  #  @param request shipping_info: {
  #    name: name
  #    phone: Phone
  #    address: Address
  #    city: City
  #    state: State
  #    zip_code: Zip code
  #    country: Country
  #    country_code: Country Code
  #    shipping_way: Shipping Way
  #    email: E-mail
  #  }
  #  @param request :order_items
  #    work_uuid:  work uuid
  #    quantity: quantity
  #  ]
  #
  # @return [JSON] Status 201
  def create
    @order = current_user.orders.build
    @order.record_order_data(request_params)
    @order.build_order(api_permitted_params.order)
    log_with_current_user @order
    if @order.save
      render json: @order,
             serializer: Api::My::OrderCreateSerializer,
             root: false,
             status: :created
    else
      render json: { status: 'error',
                     message: @order.errors.full_messages },
             status: :bad_request
    end
  end

  # User Order Pay
  #
  # Url : /api/my/orders/:order_uuid/pay
  #
  # RESTful : Patch
  #
  # Patch Example
  #   patch /api/my/orders/b48ebc3a-5a58-11e4-a8e3-3c15c2d24fd8/pay
  #
  # Return Example
  #   {
  #     "uuid": "b48ebc3a-5a58-11e4-a8e3-3c15c2d24fd8",
  #     "status": "paid",
  #     "payment": "cash_on_delivery",
  #     "order_no": "14AN000205",
  #     "payment_info": {
  #       "payment_method": "cash_on_delivery"
  #     }
  #   }
  #
  # @return [JSON] status 200
  def pay
    @order = current_user.orders.find_by(uuid: params[:order_uuid])
    if @order
      if @order.canceled? && %w(neweb/atm neweb/mmk).include?(@order.payment)
        fail OrderExpireDayAutoCancelError
      end
      @order.with_lock do
        if @order.pending?
          @order.attributes = api_permitted_params.order_pay
          log_with_current_user @order
          if @order.payment_object.pay
            render json: @order, serializer: Api::My::PayingOrderSerializer, root: false
          else
            render json: { status: 'Error',
                           message: @order.errors.full_messages,
                           id: params[:order_uuid] },
                   status: :bad_request
          end
        else
          render json: @order, serializer: Api::My::PayingOrderSerializer, root: false
        end
      end
    else
      render json: { error: "Can't find order with uuid #{params[:order_uuid]}" },
             status: :not_found
    end
  end

  # Update User Order
  #
  # Url : /api/my/orders/:uuid
  #
  # RESTful : PUT
  #
  # Put Example
  #   puts /api/my/orders/1b9a54fc-5a59-11e4-865e-3c15c2d24fd8
  #   {
  #     currency: 'USD',
  #     coupon: '',
  #     auth_token: user auth_token,
  #     billing_info: {},
  #     shipping_info: {},
  #     order_items: [
  #       work_uuid: 1bf03ce6-5a59-11e4-865e-3c15c2d24fd8,
  #       quantity: 2
  #     ]
  #   }
  #
  # Return Example
  #   {
  #     "uuid": "adc7b0b2-5a64-11e4-af43-3c15c2d24fd8",
  #     "price": 600,
  #     "currency": "TWD",
  #     "status": "pending",
  #     "payment": "paypal",
  #     "payment_method": "paypal",
  #     "coupon": null,
  #     "order_no": "14AN000149",
  #     "order_price": {
  #       "sub_total": 600,
  #       "coupon": 0,
  #       "shipping_fee": 0,
  #       "total": 600
  #     },
  #     "billing_info": {
  #       "address": "4597 Ritchie View",
  #       "city": "Hillaryview",
  #       "name": "Tavares Tillman",
  #       "phone": "1-789-966-2526 x3476",
  #       "state": "Wisconsin",
  #       "zip_code": "12818-2947",
  #       "country": "United States",
  #       "created_at": "2014-10-23T11:28:39.825+08:00",
  #       "updated_at": "2014-10-23T11:28:39.825+08:00",
  #       "country_code": "US",
  #       "shipping_way": "standard",
  #       "email": "ford_schroeder@rau.ca"
  #     },
  #     "shipping_info": {
  #       "address": "9166 Brigitte Parkway",
  #       "city": "Hankside",
  #       "name": "Keegan Weimann",
  #       "phone": "1-270-533-2650",
  #       "state": "Utah",
  #       "zip_code": "81536",
  #       "country": "United States",
  #       "created_at": "2014-10-23T11:28:39.827+08:00",
  #       "updated_at": "2014-10-23T11:28:39.827+08:00",
  #       "country_code": "US",
  #       "shipping_way": "standard",
  #       "email": "hollie.krajcik@west.info"
  #     },
  #     "order_items": [
  #       {
  #         "quantity": 2,
  #         "work_id": "ae0d8d3a-5a64-11e4-af43-3c15c2d24fd8",
  #         "work_uuid": "ae0d8d3a-5a64-11e4-af43-3c15c2d24fd8"
  #       }
  #     ]
  #   }
  #
  #  @param request auth_token [String] user auth_token
  #  @param request uuid [String] order uuid
  #  @param request currency [String] currency
  #  @param coupon [String] Coupon code
  #  @param request payment_method [String] Payment like 'paypal'
  #  @param request billing_info: {
  #    name: name
  #    phone: Phone
  #    address: Address
  #    city: City
  #    state: State
  #    zip_code: Zip code
  #    country: Country
  #    country_code: Country Code
  #    shipping_way: Shipping Way
  #    email: E-mail
  #  }
  #  @param request shipping_info: {
  #    name: name
  #    phone: Phone
  #    address: Address
  #    city: City
  #    state: State
  #    zip_code: Zip code
  #    country: Country
  #    country_code: Country Code
  #    shipping_way: Shipping Way
  #    email: E-mail
  #  }
  #  @param request :order_items
  #    work_uuid:  work uuid
  #    quantity: quantity
  #  ]
  #
  # @return [JSON] status 200
  def update
    @order = current_user.orders.pending.where(uuid: params[:uuid]).first
    if @order.present?
      @order.build_order(api_permitted_params.order)
      if @order.save
        render json: @order,
               serializer: Api::My::OrderCreateSerializer,
               root: false,
               status: :ok
      else
        render json: { status: 'error', message: @order.errors.full_messages },
               status: :bad_request
      end
    else
      render json: { status: 'error', message: 'Not found' }, status: :not_found
    end
  end

  private

  def request_params
    { platform: os_type, ip: remote_ip, user_agent: user_agent }
  end

  def validate_build_order
    if api_permitted_params.order[:order_items].blank?
      fail OrderItemsEmptyError
    end

    if api_permitted_params.order[:shipping_info][:shipping_way].nil?
      fail ShippingWayEmptyError
    end
  end

  def set_locale
    I18n.locale = params[:locale]
  rescue => e
    I18n.locale = 'en'
  end
end
