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

describe PreviewComposer::FrontBack do
  let(:composer) { PreviewComposer::FrontBack.new }

  context 'validate' do
    When { composer.valid? }
    Then { composer.errors.include?(:case_file) }
    Then { composer.errors.include?(:left_mask_file) }
    Then { composer.errors.include?(:right_mask_file) }
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
      expect(composer.case).to be_a(PreviewComposer::FrontBack::Case)
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

  describe 'left mask' do
    it 'creates blank left mask on new' do
      expect(composer.left_mask).to be_a(PreviewComposer::FrontBack::LeftMask)
      expect(composer.left_mask.composer).to be(composer)
    end

    it 'can be assigned and store to database correctly' do
      composer.left_mask # will be cached
      composer.update(left_mask_file: file, left_mask_left: 100, left_mask_top: 200)
      expect(composer.left_mask_filename).to eq('left_mask.jpg')
      expect(composer.left_mask_left).to eq(100)
      expect(composer.left_mask_top).to eq(200)
      expect(composer.left_mask.filename).to eq('left_mask.jpg')
      expect(composer.left_mask.left).to eq(100)
      expect(composer.left_mask.top).to eq(200)
    end

    def file
      tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
      ActionDispatch::Http::UploadedFile.new(filename: 'left_mask.jpg',
                                             type: 'image/jpeg',
                                             tempfile: tempfile)
    end
  end

  describe 'right mask' do
    it 'creates blank right mask on new' do
      expect(composer.right_mask).to be_a(PreviewComposer::FrontBack::RightMask)
      expect(composer.right_mask.composer).to be(composer)
    end

    it 'can be assigned and store to database correctly' do
      composer.right_mask # will be cached
      composer.update(right_mask_file: file, right_mask_left: 100, right_mask_top: 200)
      expect(composer.right_mask_filename).to eq('right_mask.jpg')
      expect(composer.right_mask_left).to eq(100)
      expect(composer.right_mask_top).to eq(200)
      expect(composer.right_mask.filename).to eq('right_mask.jpg')
      expect(composer.right_mask.left).to eq(100)
      expect(composer.right_mask.top).to eq(200)
    end

    def file
      tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
      ActionDispatch::Http::UploadedFile.new(filename: 'right_mask.jpg',
                                             type: 'image/jpeg',
                                             tempfile: tempfile)
    end
  end
end
