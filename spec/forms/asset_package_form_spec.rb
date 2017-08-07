require 'spec_helper'

describe AssetPackageForm do
  subject(:form) { AssetPackageForm.new(file: file) }
  let(:file) { ActionDispatch::Http::UploadedFile.new(tempfile: File.open(path),
                                                      filename: File.basename(path)) }
  context 'when package is valid' do
    let(:path) { Rails.root + 'spec/fixtures/asset_packages/valid_package.zip' }

    it 'is valid' do
      expect(form).to be_valid
    end

    it 'extracts zip to become entries' do
      form.valid?
      expect(form.zip_entries.size).to eq(4)
    end

    it 'merges coating entries' do
      form.valid?
      expect(form.categorized_entries[:coating].size).to eq(1)
      expect(form.categorized_entries[:coating][0][:png_file]).to be_present
      expect(form.categorized_entries[:coating][0][:png_path]).to be_present
      expect(form.categorized_entries[:coating][0][:svg_file]).to be_present
      expect(form.categorized_entries[:coating][0][:svg_path]).to be_present
    end

    it 'creates package and assets by saving' do
      form.save
      expect(form.asset_package.name).to eq('valid_package')
      expect(form.asset_package.assets.size).to eq(3)
    end
  end

  context 'when package is invalid, lost some coating svg' do
    let(:path) { Rails.root + 'spec/fixtures/asset_packages/invalid_package_lost_coating_svg.zip' }

    it 'is invalid and has some readable errors' do
      expect(form).to be_invalid
      expect(form.errors[:file]).to include(/missing file `my coating.svg`/)
    end
  end

  context 'when package is invalid, lost some coating png' do
    let(:path) { Rails.root + 'spec/fixtures/asset_packages/invalid_package_lost_coating_png.zip' }

    it 'is invalid and has some readable errors' do
      expect(form).to be_invalid
      expect(form.errors[:file]).to include(/missing file `my coating.png`/)
    end
  end
end
