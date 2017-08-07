# == Schema Information
#
# Table name: currency_types
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  code        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  rate        :float            default(1.0)
#  precision   :integer          default(0)
#

class CurrencyType < ActiveRecord::Base
  validates :name, :rate, presence: true
  validates :code, presence: true, uniqueness: true
  after_create :fee_create_currency_type, :clean_public_works_cache, :update_price_tier

  DEFAULT_DATA = {
    "USD" => { rate: 30, precision: 2 },
    "TWD" => { rate: 1, precision: 0 },
    "JPY" => { rate: 0.27, precision: 0 },
    "CNY" => { rate: 5, precision: 2 },
    "HKD" => { rate: 4.24, precision: 2 }
  }.freeze

  class << self
    def create_default_data
      return if CurrencyType.where(code: DEFAULT_DATA.keys).count == DEFAULT_DATA.size

      DEFAULT_DATA.each do |code, attrs|
        find_or_create_by({ name: code, code: code }.merge(attrs))
      end
      true
    end
  end

  def fee_create_currency_type
    Fee.find_each do |fee|
      next if fee.currencies.find_by(code: code).present?
      price = 1
      if twd_fee = fee.currencies.find_by(code: 'TWD')
        price = twd_fee.price / rate
      end
      fee.currencies.create(name: name, code: code, price: price)
    end
  end

  def clean_public_works_cache
    CleanWorksCache.perform_async
  end

  def update_price_tier
    PriceTier.find_each do |price_tier|
      prices = price_tier.prices
      if prices['TWD'].present?
        prices[code] = (prices['TWD'] / rate).round(4).ceil
      else
        prices[code] = prices.values.first
      end
      price_tier.update prices: prices
    end
  end

  COUNTRY_CURRENCY_MAPPING = {
    'TW' => 'TWD',
    'CN' => 'CNY',
    'JP' => 'JPY',
    'HK' => 'HKD',
    'US' => 'USD',
    'default' => Region.default_currency
  }

  AVAILABLE_TYPES = [
    { 'Australian Dollar' => 'AUD' },
    { 'Brazilian Real' => 'BRL' },
    { 'Canadian Dollar' => 'CAD' },
    { 'Czech Koruna' => 'CZK' },
    { 'Danish Krone' => 'DKK' },
    { 'Euro' => 'EUR' },
    { 'Hong Kong Dollar' => 'HKD' },
    { 'Hungarian Forint' => 'HUF' },
    { 'Israeli New Sheqel' => 'ILS' },
    { 'Japanese Yen' => 'JPY' },
    { 'Malaysian Ringgit' => 'MYR' },
    { 'Mexican Peso' => 'MXN' },
    { 'Norwegian Krone' => 'NOK' },
    { 'New Zealand Dollar' => 'NZD' },
    { 'Philippine Peso' => 'PHP' },
    { 'Polish Zloty' => 'PLN' },
    { 'Pound Sterling' => 'GBP' },
    { 'Russian Ruble' => 'RUB' },
    { 'Singapore Dollar' => 'SGD' },
    { 'Swedish Krona' => 'SEK' },
    { 'Swiss Franc' => 'CHF' },
    { 'Taiwan New Dollar' => 'TWD' },
    { 'Thai Baht' => 'THB' },
    { 'Turkish Lira' => 'TRY' },
    { 'U.S. Dollar' => 'USD' },
    { 'China Yuan' => 'CNY' }
  ]

  def self.available_types
    types = CurrencyType::AVAILABLE_TYPES.delete_if { |el| CurrencyType.all.map(&:code).include?(el.keys[0]) }
    types.map(&:first)
  end

  def self.by_country(country)
    COUNTRY_CURRENCY_MAPPING[country] || COUNTRY_CURRENCY_MAPPING['default']
  end
end
