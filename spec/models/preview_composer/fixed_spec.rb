# == Schema Information
#
# Table name: preview_composers
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  model_id    :integer
#  layers      :text
#  created_at  :datetime
#  updated_at  :datetime
#  key         :string(255)
#  available   :boolean          default(FALSE), not null
#  position    :integer
#  template_id :integer
#

require 'spec_helper'

describe PreviewComposer::Fixed do
  let(:composer) { PreviewComposer::Fixed.new }

  context 'validate' do
    When { composer.valid? }
    Then { composer.errors.include?(:image_file) }
  end

  describe 'image' do
    it 'creates blank case on new' do
      expect(composer.image).to be_a(PreviewComposer::Fixed::Image)
      expect(composer.image.composer).to be(composer)
    end

    it 'can be assigned and store to database correctly' do
      composer.image # will be cached
      composer.update(image_file: file)
      expect(composer.image_filename).to eq('case.jpg')
      expect(composer.image.filename).to eq('case.jpg')
    end

    def file
      tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
      ActionDispatch::Http::UploadedFile.new(filename: 'case.jpg',
                                             type: 'image/jpeg',
                                             tempfile: tempfile)
    end
  end
end
