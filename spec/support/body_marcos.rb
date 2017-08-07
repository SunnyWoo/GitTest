require 'paypal-sdk-rest'

module BodyMarcos

  def shipping_fee
    Fee.where(name: '運費').first
  end

  def setup_shipping_fee
    shipping_fee.destroy
    create(:fee, name: '運費')
  end

  def with_versioning
    was_enabled = PaperTrail.enabled?
    PaperTrail.enabled = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
    end
  end

  def paypal_payment
    payment = PayPal::SDK::REST::Payment.new({
      :intent => "sale",
      :payer => {
        :payment_method => "credit_card",
        :funding_instruments => [{
          :credit_card => {
            :type => "visa",
            :number => "4417119669820331",
            :expire_month => "11",
            :expire_year => "2018",
            :cvv2 => "874",
            :first_name => "Joe",
            :last_name => "Shopper",
            :billing_address => {
              :line1 => "52 N Main ST",
              :city => "Johnstown",
              :state => "OH",
              :postal_code => "43210",
              :country_code => "US" }}}]},
      :transactions => [{
        :item_list => {
          :items => [{
            :name => "item",
            :sku => "item",
            :price => "99.90",
            :currency => "USD",
            :quantity => 1 }]},
        :amount => {
          :total => "99.90",
          :currency => "USD" },
        :description => "This is the payment transaction description." }]})
    if payment.create
      payment
    else
      payment.error
    end
  end

  def billing_profile_params
    params = {
      name: Faker::Name.name,
      phone: Faker::PhoneNumber.phone_number,
      address: Faker::Address.street_address,
      city: Faker::Address.city,
      state: Faker::AddressUS.state,
      zip_code: Faker::AddressUS.zip_code,
      country: Faker::Address.country('US'),
      country_code: 'US',
      shipping_way: 'standard',
      email: Faker::Internet.email
    }
  end

  def create_basic_currencies
    CurrencyType.create_default_data
  end

  def currency_conversion_rate(from, to)
    (CurrencyType.find_by!(code: from).rate / CurrencyType.find_by!(code: to).rate)
  end
end
