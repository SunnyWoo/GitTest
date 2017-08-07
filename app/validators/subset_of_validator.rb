class SubsetOfValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    superset = options[:in]
    if (value & superset) != value
      record.errors.add(attribute, :inclusion)
    end
  end
end
