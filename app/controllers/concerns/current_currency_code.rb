module CurrentCurrencyCode
  extend ActiveSupport::Concern
  include CurrentCountryCode

  included do
    helper_method :current_currency_code
    helper_method :current_currency
  end

  #
  # 透過使用者目前的國家，設定 currency
  #
  # @return String currency
  def current_currency_code
    @current_currency_code ||= if Region.china?
                                 CurrencyType.by_country('CN')
                               else
                                 CurrencyType.by_country(current_country_code)
                               end
  end

  def current_currency
    ActiveSupport::Deprecation.warn '`current_currency` is deprecated. use `current_currency_code` instead.'
    current_currency_code
  end
end
