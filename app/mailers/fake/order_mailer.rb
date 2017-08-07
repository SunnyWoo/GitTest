class Fake::OrderMailer < OrderMailer
  def receipt(email = 'to@example.org', locale = 'en')
    @user = FakeUser.new
    @order = FakeOrder.new
    @billing_info = FakeBillingInfo.new
    @shipping_info = FakeBillingInfo.new
    # @fee = FakeFee.new
    I18n.with_locale(locale) do
      mail to: email, subject: I18n.t('email.order.receipt.subject'), template_path: 'order_mailer', template_name: 'receipt'
    end
  end

  def receipt_with_status(email = 'to@example.org', locale = 'en')
    @user = FakeUser.new
    @order = FakeOrder.new
    @billing_info = FakeBillingInfo.new
    @shipping_info = FakeBillingInfo.new
    @cash_on_delivery = Fee.find_by(name: 'cash_on_delivery').price_in_currency('TWD')
    I18n.with_locale(locale) do
      mail to: email, subject: I18n.t('email.order.receipt_with_status.subject'), template_path: 'order_mailer', template_name: 'receipt_with_status'
    end
  end

  def download(email = 'to@example.org', locale = 'en')
    @user = FakeUser.new
    @order = FakeOrder.new
    I18n.with_locale(locale) do
      mail to: email, subject: I18n.t('email.order.download.subject'), template_path: 'order_mailer', template_name: 'download'
    end
  end

  def ship(email = 'to@example.org', locale = 'en')
    @user = FakeUser.new
    @order = FakeOrder.new
    @billing_info = FakeBillingInfo.new
    @shipping_info = FakeBillingInfo.new
    @today = I18n.l(Date.today)
    I18n.with_locale(locale) do
      mail to: email, subject: I18n.t('email.order.ship.subject'), template_path: 'order_mailer', template_name: 'ship'
    end
  end
end

class FakeUser
  def username
    "Maile Test Name"
  end
end

class FakeOrder
  def order_no
    '147G001262'
  end

  def order_items
    [FakeOrderItem.new, FakeOrderItem.new]
  end

  def currency
    'USD'
  end

  def price
    289.8
  end

  def coupon
    FakeCoupon.new
  end

  def shipping_price
    100
  end

  def payment
    'cash_on_delivery'
  end

  def render_twd_shipping_price
    30
  end

  def shipping_info
    FakeShippingInfo.new
  end

  def order_items_total
    99.9 * 2
  end

  def render_twd_price
    289.8 * 30
  end
end

class FakeOrderItem
  def itemable
    FakeWork.new
  end

  def quantity
    1
  end

  def price_in_currency(currency)
    99.9
  end

  def itemable_order_image
    FakeImage.new
  end

  def itemable_name
    "blah"
  end

  def itemable_model
    "iPhone 5/5s"
  end

  def itemable_cover_image
    FakeImage.new
  end

  def aasm_state
    'pending'
  end
end

class FakeWork
  def cover_image
    FakeImage.new
  end

  def name
    Faker::Name.name
  end

  def description
    'description'
  end

  def model
    FakeModel.new
  end

  def price_in_currency(currency)
    99.9
  end
end

class FakeImage
  def url(type = nil)
    'http://fakeimg.pl/1536x2048/?text=TestCover'
  end
end

class FakeBillingInfo
  def name
    Faker::Name.name
  end

  def address
    Faker::Address.street_address
  end

  def city_state
    Faker::Address.city
  end

  def zip_code
    Faker::AddressUS.zip_code
  end

  def country
    Faker::Address.country('US')
  end

  def phone
    Faker::PhoneNumber.phone_number
  end

  def shipping_way
    'express'
  end

  def express?
    true
  end

  def cash_on_delivery?
    true
  end

  def country_code
    'en'
  end
end

class FakeFee
  def price_in_currency(currency)
    '100'
  end
end

class FakeCoupon
  def price(currency)
    10
  end
end

class FakeModel
  def name
    'model iphone5s'
  end

  def friendly_name
    'iPhone5s cases'
  end
end

class FakeShippingInfo
  def name
    Faker::Name.name
  end

  def address
    Faker::Address.street_address
  end

  def city_state
    Faker::Address.city
  end

  def zip_code
    Faker::AddressUS.zip_code
  end

  def country
    Faker::Address.country('US')
  end

  def phone
    Faker::PhoneNumber.phone_number
  end

  def shipping_way
    'express'
  end

  def express?
    true
  end

  def cash_on_delivery?
    true
  end
end