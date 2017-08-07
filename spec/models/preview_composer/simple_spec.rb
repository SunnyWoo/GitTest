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

describe PreviewComposer::Simple do
  let(:composer) { PreviewComposer::Simple.new }

  context 'validate' do
    When { composer.valid? }
    Then { composer.errors.include?(:case_file) }
    And { composer.errors.include?(:mask_file) }
    And { composer.errors.include?(:base) }
  end

  describe '#background' do
    it 'creates blank background on new' do
      expect(composer.background).to be_a(PreviewComposer::Common::Background)
    end

    it 'can be assigned and store to database correctly' do
      composer.background # will be cached
      composer.update(background_width: 640, background_height: 480)
      expect(composer.background_width).to eq(640)
      expect(composer.background_height).to eq(480)
      expect(composer.background.width).to eq(640)
      expect(composer.background.height).to eq(480)
    end

    it 'can be save with a file' do
      composer.background # will be cached
      composer.update(background_file: file)
      expect(composer.background_filename).to eq('background.jpg')
      expect(composer.background.filename).to eq('background.jpg')
    end

    def file
      tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
      ActionDispatch::Http::UploadedFile.new(filename: 'background.jpg',
                                             type: 'image/jpeg',
                                             tempfile: tempfile)
    end
  end

  describe 'case' do
    it 'creates blank case on new' do
      expect(composer.case).to be_a(PreviewComposer::Simple::Case)
      expect(composer.case.composer).to be(composer)
    end

    it 'can be assigned and store to database correctly' do
      composer.case # will be cached
      composer.update(case_file: file)
      expect(composer.case_filename).to eq('case.jpg')
      expect(composer.case.filename).to eq('case.jpg')
    end

    def file
      tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
      ActionDispatch::Http::UploadedFile.new(filename: 'case.jpg',
                                             type: 'image/jpeg',
                                             tempfile: tempfile)
    end
  end
end
