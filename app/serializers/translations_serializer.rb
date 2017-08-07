module TranslationsSerializer
  extend ActiveSupport::Concern

  def default_translations
    I18n.available_locales.inject({}) do |hash, locale|
      hash[locale.to_s] = ''
      hash
    end
  end

  module ClassMethods
    def translated_attribute(attribute)
      translated_attribute_name = :"#{attribute}_translations"

      define_method translated_attribute_name do
        default_translations.merge(object.send(translated_attribute_name))
      end

      attribute translated_attribute_name
    end

    def translated_attributes(*attributes)
      attributes.each do |attribute|
        translated_attribute(attribute)
      end
    end
  end
end
