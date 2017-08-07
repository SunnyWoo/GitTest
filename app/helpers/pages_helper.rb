module PagesHelper
  def our_story_margin
    if I18n.locale == :en
      'margin-bottom: 195px;'
    else
      'margin-bottom: 140px;'
    end
  end

  def our_mission_margin
    case I18n.locale
    when :en
      'margin-bottom: 198px;'
    else
      'margin-bottom: 115px;'
    end
  end

  def fanpage_url
    case current_country_code
    when 'TW', 'HK', 'CN', 'MO'
      'https://www.facebook.com/commandpzh'
    when 'JP'
      'https://www.facebook.com/commandpjp'
    else
      'https://www.facebook.com/hicommandp'
    end
  end

  def font_for_en
    case I18n.locale
    when :en
      'web-font'
    else
      ''
    end
  end

  def current_locale(locale)
    if I18n.locale == locale
      'current'
    end
  end
end
