class ImageSizeValidator < ActiveModel::EachValidator
  def initialize(options)
    [:width, :height].each do |length|
      next unless options[length] and options[length].is_a?(Hash)
      if range = (options[length].delete(:in) || options[length].delete(:within))
        raise ArgumentError, ':in and :within must be a Range' unless range.is_a?(Range)
        options[length][:min], options[length][:max] = range.min, range.max
      end
    end
    super
  end

  def validate_each(record, attribute, _value)
    unless record.send("#{attribute}_cache").nil?
      [:width, :height].each do |length|
        next unless options[length]
        if options[length].is_a?(Hash)
          if options[length][:min] && record.send(attribute).send(length) < options[length][:min]
            record.errors[attribute] << I18n.t('errors.messages.image.greater_than_or_equal_to', length: length, count: options[length][:min])
          end
          if options[length][:max] && record.send(attribute).send(length) > options[length][:max]
            record.errors[attribute] << I18n.t('errors.messages.image.less_than_or_equal_to', length: length, count: options[length][:max])
          end
          if options[length][:inclusion] && !record.send(attribute).send(length).in?(options[length][:inclusion])
            record.errors[attribute] << I18n.t('errors.messages.image.equal_to', length: length, count: options[length][:inclusion].join(' | '))
          end
        elsif record.send(attribute).send(length) != options[length]
          record.errors[attribute] << I18n.t('errors.messages.image.equal_to', length: length, count: options[length])
        end
      end
    end
  end
end
