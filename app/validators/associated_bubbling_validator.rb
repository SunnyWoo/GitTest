class AssociatedBubblingValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    Array(value).each do |v|
      if v && !v.valid?
        v.errors.full_messages.each do |msg|
          record.errors.add(attribute, msg, options.merge(:value => value))
        end
      end
    end
  end
end