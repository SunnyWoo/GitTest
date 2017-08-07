class CurrencyExchangeError < ApplicationError
  def message
    I18n.t('errors.currency_exchange_error')
  end
end
