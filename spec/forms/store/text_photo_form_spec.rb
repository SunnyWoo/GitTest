require 'spec_helper'

describe Store::TextPhotoForm do
  let(:template) { create :product_template }
  subject { Store::TextPhotoForm.new template, {} }
  it { should validate_numericality_of(:max_font_size) }
  it { should validate_numericality_of(:position_x) }
  it { should validate_numericality_of(:position_y) }
  it { should validate_numericality_of(:rotation) }
  it { should validate_numericality_of(:min_font_size) }
  it { should validate_numericality_of(:max_font_width) }
  it { should_not allow_value(11).for(:max_font_size) }
  it { should allow_value(12).for(:max_font_size) }
  it { should_not allow_value(8).for(:min_font_size) }
  it { should allow_value(10).for(:min_font_size) }
  it { should_not allow_value('black').for(:color) }
  it { should allow_value('#170810').for(:color) }
  %i(position_x position_y rotation).each do |attr|
    it { should allow_value(1234.5678).for(attr) }
  end
  it { should validate_inclusion_of(:font_name).in_array(CommandP::Resources.fonts.map(&:name)) }

  Given(:template) { create :product_template }
  Given(:form) { Store::TextPhotoForm.new(template, font_name: 'billy', template_image: image, template_type: 'text_and_photo') }
  Given(:image) do
    tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
    ActionDispatch::Http::UploadedFile.new(filename: 'great-design.jpg', tempfile: tempfile)
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

  context '#save' do
    context 'updates template when valid' do
      When { allow(form).to receive(:valid?).and_return(true) }
      Then { expect { form.save }.to change { template.settings } }
      And { form.template.template_image.present? }
      And { form.template.template_type == 'text_and_photo' }
    end

    context 'updates nothing when invalid' do
      When { allow(form).to receive(:valid?).and_return(false) }
      Then { expect { form.save }.not_to change { template.settings } }
      And { form.template.reload.template_image.blank? }
      And { form.template.template_type.nil? }
    end
  end
end
