class CurrencyExchangeService
  attr_accessor :price, :currency, :target_currency

  def initialize(price, currency, target_currency)
    # 目前只允许与 TWD 换算
    fail CurrencyExchangeError unless 'TWD'.in? [currency, target_currency]
    @price = price
    @currency = currency
    @target_currency = target_currency
  end

  def execute
    price.send(action, rate).round(precision)
  end

  private

  def action
    currency == 'TWD' ? '/' : '*'
  end

  def currency_type
    if currency == 'TWD'
      CurrencyType.find_by_code(target_currency)
    else
      CurrencyType.find_by_code(currency)
    end
  end

  def precision
    currency_type.precision
  end

  def rate
    currency_type.rate
  end
end
