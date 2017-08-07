class FinityNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.nil? || value.nan? || value == Float::INFINITY || value == -Float::INFINITY
      record.errors.add(attribute, :not_a_number)
    end
  end
end
