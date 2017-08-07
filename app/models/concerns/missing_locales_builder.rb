module MissingLocalesBuilder
  def build_missing_locale_set
    missing_locales = I18n.available_locales - translations.pluck(:locale).map(&:to_sym)
    missing_locales.each do |missing_locale|
      translations.build(locale: missing_locale)
    end if missing_locales.length > 0
  end
end
