require 'spec_helper'

describe Store::PhotoOnlyForm do
  Given(:template) { create :product_template }
  Given(:form) { Store::PhotoOnlyForm.new(template, template_image: image, template_type: 'photo_only') }
  Given(:image) do
    tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
    ActionDispatch::Http::UploadedFile.new(filename: 'great-design.jpg', tempfile: tempfile)
  end
  context '#save' do
    context 'updates template\'s template_image when valid' do
      When do
        allow(form).to receive(:valid?).and_return(true)
        form.save
      end
      Then { template.template_image.present? }
      And { template.template_type == 'photo_only' }
      And { template.settings.blank? }
    end

    context 'updates nothing when invalid' do
      When { allow(form).to receive(:valid?).and_return(false) }
      When do
        allow(form).to receive(:valid?).and_return(false)
        form.save
      end
      Then { template.reload.template_image.blank? }
      And { template.template_type.nil? }
    end
  end

  context '.check_template_image_dimensions' do
    context 'passes validation if difference of dimensions between template_image and product in 5pxs' do
      before do
        allow(form).to receive(:product_width).and_return(800)
        allow(form).to receive(:product_height).and_return(600)
        allow(form).to receive_message_chain('template_image.width').and_return(803)
        allow(form).to receive_message_chain('template_image.height').and_return(597)
      end
      When { form.valid? }
      Then { form.errors[:template_image].blank? }
    end

    context 'does not pass validation if difference of dimensions between template_image and product over 5pxs' do
      before do
        allow(form).to receive(:product_width).and_return(800)
        allow(form).to receive(:product_height).and_return(600)
        allow(form).to receive_message_chain('template_image.width').and_return(810)
        allow(form).to receive_message_chain('template_image.height').and_return(590)
      end
      When { form.valid? }
      Then { form.errors[:template_image].present? }
    end
  end
end
