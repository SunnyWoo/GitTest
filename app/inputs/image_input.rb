# app/inputs/image_preview_input.rb
class ImageInput < SimpleForm::Inputs::FileInput
  def input(_wrapper_options = nil)
    out = ActiveSupport::SafeBuffer.new
    id = template.dom_id(object, "preview_#{attribute_name}_for")
    content = if object.send(attribute_name).present?
                if object.send(attribute_name).file.try(:extension) == 'pdf'
                  template.content_tag(:div, class: 'pdf-logo-uploader-previewer', id: id) do
                    template.image_tag('pdf_logo.png') +
                      template.link_to("下載檔案", object.send(attribute_name).url, target: '_blank')
                  end
                else
                  img = template.image_tag(object.send(attribute_name).url) if object.send(attribute_name).present?
                  template.content_tag(:div, img, class: 'upload-previewer', id: id)
                end
              end
    out << content
    out << @builder.file_field(attribute_name, input_html_options.merge(data: { preview_at: "##{id}" }, class: 'simple_form_image_input'))
  end
end
