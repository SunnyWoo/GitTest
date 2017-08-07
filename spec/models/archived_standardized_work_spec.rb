# == Schema Information
#
# Table name: archived_standardized_works
#
#  id               :integer          not null, primary key
#  uuid             :string(255)
#  slug             :string(255)
#  original_work_id :integer
#  user_id          :integer
#  user_type        :string(255)
#  model_id         :integer
#  name             :string(255)
#  price_tier_id    :integer
#  featured         :boolean
#  print_image      :string(255)
#  image_meta       :json
#  created_at       :datetime
#  updated_at       :datetime
#  product_code     :string(255)
#  variant_id       :integer
#

require 'rails_helper'

RSpec.describe ArchivedStandardizedWork, type: :model do
  it { should validate_presence_of(:user_id) }

  let(:image) do
    tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
    ActionDispatch::Http::UploadedFile.new(filename: 'great-design.jpg', type: 'image/svg+xml', tempfile: tempfile)
  end
  let(:work) { create(:archived_standardized_work) }
  let(:product) { create(:product_model) }
  let(:work_with_print_image) { create(:standardized_work, product: product, print_image: image).create_archive }
  it_behaves_like 'an itemable'
  it '#china_archive_attributes' do
    expect(work.china_archive_attributes).to eq(remote_product_key: work.product.remote_key,
                                                cover_image: nil,
                                                print_image: work.print_image.url,
                                                order_image: work.order_image.try(:url),
                                                name: work.name)
  end

  context '#is_public?' do
    before { expect(work).to receive(:published?).and_return true }
    Then { work.is_public? }
  end

  context 'included QiniuStoreImage' do
    ArchivedStandardizedWork.const_get(:QiniuStoreImage) == QiniuStoreImage
  end

  context '#build_fake_layers' do
    it 'return nil whent print_image is empty' do
      expect(work.build_fake_layers).to be_falsey
    end

    it 'return layers whent print_image is not empty' do
      work = build(:standardized_work, print_image: image)
      expect(work.build_fake_layers.count).to eq(1)
      layer = work.build_fake_layers.first
      expect(layer.layer_type).to eq('fake')
      expect(layer.scale_x).to eq(0.5)
      expect(layer.scale_y).to eq(0.5)
      expect(layer.filtered_image.present?).to be_truthy
      expect(layer.image.present?).to be_truthy
    end
  end

  context '#build_print_image' do
    it 'raise error when print_image is empty' do
      expect(work.print_image.present?).to be_falsey
      expect{ work.build_print_image }.to raise_error(NoMethodError)
    end

    it 'return true when print_image is not empty' do
      expect(work_with_print_image.print_image.present?).to be_truthy
      expect(work_with_print_image.build_print_image).to be_truthy
    end
  end

  context 'when print_image was change' do
    context 'and product enable_white is false' do
      it 'print_image gray will not present' do
        expect(work_with_print_image.print_image.present?).to be_truthy
        expect(work_with_print_image.print_image.gray.present?).to be_falsey
      end
    end

    context 'and product enable_white is true' do
      let(:product) { create(:product_model, :enable_white) }

      it 'print_image gray will present' do
        expect(work_with_print_image.print_image.present?).to be_truthy
        expect(work_with_print_image.print_image.gray.present?).to be_truthy
      end
    end
  end
end
