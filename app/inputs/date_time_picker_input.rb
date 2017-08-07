class DateTimePickerInput < SimpleForm::Inputs::Base
  def input(*)
    @builder.text_field(attribute_name, input_html_options.merge(merge_options))
  end

  def merge_options
    format_value = value.strftime('%F %H:%M') if value
    { class: 'form-control datetimepicker', value: format_value }
  end

  def value
    object.send(attribute_name)
  end
end
