require 'spec_helper'

describe DefaultUploader do
  describe '#mime_type' do
    let(:model) { double('Model', id: 'WHATEVER') }
    let(:uploader) do
      uploader = DefaultUploader.new(model, :file_column)
      allow(uploader).to receive(:filename).and_return('FILENAME')
      uploader
    end

    context 'with jpg file named xxx.jpg' do
      before do
        file_path = File.join(Rails.root, 'spec', 'fixtures', 'test.jpg')
        File.open(file_path) { |f| uploader.store!(f) }
      end

      after { uploader.remove! }

      it 'returns image/jpeg' do
        expect(uploader.mime_type).to eq('image/jpeg')
      end
    end

    context 'with jpg file named xxx.png' do
      before do
        file_path = File.join(Rails.root, 'spec', 'fixtures', 'jpg_file_with_png_ext.png')
        File.open(file_path) { |f| uploader.store!(f) }
      end

      after { uploader.remove! }

      it 'returns image/jpeg' do
        expect(uploader.mime_type).to eq('image/jpeg')
      end
    end

    context 'with jpg file not include extention in name' do
      before do
        file_path = File.join(Rails.root, 'spec', 'fixtures', 'jpg_file_without_ext')
        File.open(file_path) { |f| uploader.store!(f) }
      end

      after { uploader.remove! }

      it 'returns image/jpeg' do
        expect(uploader.mime_type).to eq('image/jpeg')
      end
    end
  end
end
