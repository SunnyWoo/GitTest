# == Schema Information
#
# Table name: archived_works
#
#  id                  :integer          not null, primary key
#  original_work_id    :integer
#  artwork_id          :integer
#  model_id            :integer
#  cover_image         :string(255)
#  print_image         :string(255)
#  fixed_image         :string(255)
#  image_meta          :json
#  created_at          :datetime
#  updated_at          :datetime
#  slug                :string(255)
#  uuid                :string(255)
#  ai                  :string(255)
#  pdf                 :string(255)
#  prices              :json
#  user_type           :string(255)
#  user_id             :integer
#  application_id      :integer
#  name                :string(255)
#  product_code        :string(255)
#  product_template_id :integer
#  variant_id          :integer
#

require 'spec_helper'

describe ArchivedWork do
  it_behaves_like 'an itemable'

  it { should belong_to(:product_template) }
  it { should validate_presence_of(:user_id) }

  describe 'after update' do
    it 'touchs every order item' do
      work = create(:work).create_archive
      order_item = create(:order_item, itemable: work)
      work.update(slug: 'hello')
      expect(order_item.updated_at).not_to eq(order_item.reload.updated_at)
    end
  end

  context 'store prices' do
    it 'when original work destroy' do
      work = create(:work)
      archive_work = work.create_archive
      expect(work.prices).to eq(archive_work.prices)
      work.destroy
      expect(archive_work.tap(&:reload).prices).not_to be nil
    end
  end

  describe '#work_type' do
    it 'always be is_private' do
      expect(create(:archived_work).work_type).to eq('is_private')
    end
  end

  context 'included QiniuStoreImage' do
    ArchivedWork.const_get(:QiniuStoreImage) == QiniuStoreImage
  end

  context '#build_print_image' do
    let(:archived_work) { create(:archived_work) }
    let(:layer) { create(:layer, layer_type: 'fake') }
    let(:work_with_layers) { create(:work, layers: [layer]) }
    let(:archived_work_with_layers) { work_with_layers.create_archive }

    it 'return true when layers is empty' do
      expect(archived_work.layers.count).to eq(0)
      expect(archived_work.print_image.present?).to be_falsey
      expect(archived_work.build_print_image).to be_truthy
      expect(archived_work.print_image.present?).to be_truthy
    end

    it 'return true when layers is not empty' do
      expect(archived_work_with_layers.layers.count).to eq(1)
      expect(archived_work_with_layers.print_image.present?).to be_falsey
      expect(archived_work_with_layers.build_print_image).to be_truthy
      expect(archived_work_with_layers.print_image.present?).to be_truthy
    end
  end

  context 'enqueue_build_previews' do
    context 'when create_order_image_by_cover_image is true' do
      Given(:product) { create :product_model, create_order_image_by_cover_image: true }
      context 'increases PreviewBuilder jobs to create order_image by cover_image with which stored' do
        Given!(:archived_work) { create :archived_work, product: product }
        Then { assert_equal 1, PrintImageBuilder.jobs.size }
        And { assert_equal 1, PreviewsBuilder.jobs.size }
        And { PreviewsBuilder.jobs.first['args'] == [archived_work.to_gid.to_s, 'cover_image', false] }
      end
    end

    context 'when create_order_image_by_cover_image is false' do
      context 'increases PreviewBuilder jobs to create order_image by print_image with which stored' do
        Given!(:archived_work) { create :archived_work, print_image: fixture_file_upload('test.jpg', 'image/jpeg') }
        Then { assert_equal 1, PreviewsBuilder.jobs.size }
        And { PreviewsBuilder.jobs.first['args'] == [archived_work.to_gid.to_s, 'print_image', true] }
      end
    end
  end
end
