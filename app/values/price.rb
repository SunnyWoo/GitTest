class Price
  include Comparable

  I18N_SCOPE = "value.price".freeze
  DEFAULT_CURRENCY = Region.default_currency.freeze
  BASE_CURRENCIES = %w(TWD CNY USD JPY HKD).freeze

  attr_reader :currency, :prices

  delegate :as_json, :to_json, to: :prices
  delegate :normalize, to: :class

  class << self
    def build_by_value(value, currency = DEFAULT_CURRENCY)
      new(currency.to_s => value)
    end

    def normalize(value, currency = Region.default_currency)
      return nil if value.nil?

      rate = case currency
             when 'TWD', 'JPY' then 1.0
             else 100.0
             end
      v = value
      # round(4) 是為了防止某些浮點數計算誤差 如 9.27 - 1.86 = 7.40999999999 (實為 7.41)

      v = (v * rate).round(4)
      v = yield(v) if block_given?
      v / rate
    end

    def in_currency(base_value, base_currency, target_currency)
      base_currency_type   = CurrencyType.find_by!(code: base_currency)
      target_currency_type = CurrencyType.find_by!(code: target_currency)

      ans = normalize(base_value, target_currency) do |v|
        v * base_currency_type.rate / target_currency_type.rate
      end

      target_currency.in?(%w(TWD JPY)) ? ans.floor : ans.round(target_currency_type.precision)
    end
  end

  def initialize(hash_or_value = 0.0, currency = DEFAULT_CURRENCY)
    @prices = if hash_or_value.is_a?(Hash)
                raise ArgumentError, I18n.t('error.invalid_currency', scope: I18N_SCOPE, base: BASE_CURRENCIES) if (hash_or_value.keys & BASE_CURRENCIES).empty?
                hash_or_value
              else
                { currency => normalize(hash_or_value.to_f, currency) }
              end
    raise ArgumentError if @prices.empty?
    @currency = currency
    @cache = {}

    ensure_currency_value
  end

  def fetch(target_currency)
    @prices.fetch(target_currency){
      @cache[target_currency] = in_currency(target_currency)
    }
  end

  alias_method :[], :fetch

  def value
    @prices[currency] && @prices[currency].to_f
  end

  def +(other)
    case other
    when Price
      currencies = given_currencies
      new_prices = currencies.each_with_object({}) do |currency, h|
        h[currency] = @prices[currency] + other[currency]
      end
      self.class.new(new_prices, currency)
    else
      self.class.new(currency => value + other.to_f)
    end
  end

  def -(other)
    self + other * -1
  end

  # round(4) 是為了防止某些浮點數計算誤差 如 9.27 - 1.86 = 7.40999999999 (實為 7.41)
  def *(other)
    new_prices = given_currencies.each_with_object({}) do |currency, h|
      h[currency] = (@prices[currency] * other).round(4)
    end
    self.class.new(new_prices, currency)
  end

  def /(other)
    self * (1.0 / other)
  end

  def <=>(other)
    value <=> other[currency]
  end

  def ==(other)
    value == other.to_f
  end

  def given_currencies
    @prices.keys
  end

  def to_h
    (BASE_CURRENCIES | given_currencies).each_with_object({}) do |c, h|
      h[c] = fetch(c)
    end
  end

  def to_f
    value
  end

  def humanize
    "#{currency} $#{value}"
  end

  def with_currency!(target_currency)
    @prices[target_currency] ||= fetch(target_currency)
    @currency = target_currency
    self
  end

  def with_currency(target_currency)
    Price.new(@prices, target_currency)
  end

  def floor
    prices = @prices.each_with_object({}) do |(currency, value), h|
      h[currency] = floored_value(value, currency)
    end
    Price.new(prices, currency)
  end

  def ceil
    prices = @prices.each_with_object({}) do |(currency, value), h|
      h[currency] = ceiled_value(value, currency)
    end
    Price.new(prices, currency)
  end

  private

  def ensure_currency_value
    return if @prices[currency]
    ref_currency, ref_value = @prices.first
    @prices[currency] = self.class.in_currency(ref_value, ref_currency, currency)
  end

  def ceiled_value(value, currency)
    processed_value(value, currency, :ceil)
  end

  def floored_value(value, currency)
    processed_value(value, currency, :floor)
  end

  def processed_value(value, currency, method)
    return nil if value.nil?
    self.class.normalize(value, currency, &method.to_sym)
  end

  def in_currency(target_currency)
    self.class.in_currency(value, currency, target_currency)
  end
end
