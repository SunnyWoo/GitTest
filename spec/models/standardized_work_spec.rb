# == Schema Information
#
# Table name: standardized_works
#
#  id                :integer          not null, primary key
#  uuid              :string(255)
#  user_id           :integer
#  user_type         :string(255)
#  model_id          :integer
#  name              :string(255)
#  slug              :string(255)
#  aasm_state        :string(255)
#  price_tier_id     :integer
#  featured          :boolean          default(FALSE), not null
#  print_image       :string(255)
#  image_meta        :json
#  created_at        :datetime
#  updated_at        :datetime
#  deleted_at        :datetime
#  impressions_count :integer          default(0)
#  cradle            :integer          default(0)
#  bought_count      :integer          default(0)
#  content           :text
#  variant_id        :integer
#

require 'rails_helper'

RSpec.describe StandardizedWork, type: :model do
  let(:work) { create(:standardized_work) }
  let(:image) do
    tempfile = File.new(Rails.root + 'spec/fixtures/great-design.jpg')
    ActionDispatch::Http::UploadedFile.new(filename: 'great-design.jpg', type: 'image/svg+xml', tempfile: tempfile)
  end
  let(:product) { create(:product_model) }
  let(:work_with_print_image) { build(:standardized_work, product: product, print_image: image) }

  it_behaves_like 'an itemable'
  it_behaves_like 'acts_as_taggable'

  it { is_expected.to have_many(:previews) }
  it { is_expected.not_to allow_value(nil).for(:product) }
  it { is_expected.not_to allow_value(nil).for(:user) }
  it { is_expected.not_to allow_value(nil).for(:name) }
  it { is_expected.not_to allow_value('    ').for(:name) }
  it { should define_enum_for(:cradle).with(Work::CRADLE_TYPES) }

  it 'can be created' do
    expect(work).to be_valid
  end

  it { expect(work.original_prices).to eq(work.product.prices) }

  describe '#aasm_state' do
    it 'starts with draft state' do
      expect(work).to be_draft
    end

    it 'transition from draft to published by publish' do
      expect { work.publish }.to change { work.aasm_state }.from('draft').to('published')
    end

    it 'transition from published to pulled by pull' do
      work.publish
      expect { work.pull }.to change { work.aasm_state }.from('published').to('pulled')
    end

    it 'transition from pulled to published by publish' do
      work.publish
      work.pull
      expect { work.publish }.to change { work.aasm_state }.from('pulled').to('published')
    end
  end

  describe '#archived_attributes' do
    it 'returns attributes that can be used to build archived work' do
      work = create(:standardized_work)
      expect(work.archived_attributes).to eq(
        user_id: work.user_id,
        user_type: work.user_type,
        name: work.name,
        model_id: work.model_id,
        variant_id: work.variant_id,
        price_tier_id: work.price_tier_id,
        featured: work.featured,
        print_image: work.print_image,
        previews_attributes: work.previews.map(&:archived_attributes),
        output_files_attributes: work.output_files.map(&:archived_attributes),
        product_code: work.product_code
      )
    end
  end

  describe '#create_archive' do
    it 'creates archived work by archived attributes' do
      work = create(:standardized_work)
      archived_work = work.create_archive

      expect(archived_work).to be_persisted
    end
  end

  describe '#last_archive' do
    context 'when no archives' do
      it 'creates archive and return it' do
        work = create(:standardized_work)
        expect(work.last_archive).to be_a(ArchivedStandardizedWork)
      end
    end

    context 'when have any archive' do
      it 'returns last archive' do
        work = create(:standardized_work)
        archive = work.create_archive
        expect(work.last_archive).to eq(archive)
      end
    end
  end

  describe '#tags' do
    context 'when add tag' do
      Given(:tag) { create :tag }
      Given(:standardized_work) { create :standardized_work }
      When { standardized_work.tags << tag }
      Then { standardized_work.tag_ids.include?(tag.id) }
    end

    context 'when destroy tag' do
      Given(:tag_1) { create :tag }
      Given(:tag_2) { create :tag }
      Given(:standardized_work) { create :standardized_work, tag_ids: Tag.all.pluck(:id) }
      When { standardized_work.update(tag_ids: [tag_1.id]) }
      Then { standardized_work.tags.include?(tag_1) }
      Then { standardized_work.tags.include?(tag_2) == false }
    end
  end

  describe '#work_type' do
    it 'always be is_public' do
      expect(work.work_type).to eq('is_public')
    end
  end

  describe '#series_works' do
    it 'returns the standardized_works with the same name and must be published' do
      work = create :standardized_work, :with_iphone6_model, name: 'Jedi Council'
      series_work = create :standardized_work, :with_ipad_air2_model, name: 'Jedi Council'
      my_design_work = create :standardized_work
      series_works = work.series_works(5)
      expect(series_works).to include series_work
      expect(series_works).not_to include my_design_work
    end
  end

  describe '#designer_works' do
    it 'returns the standardized_works belonging to the same designer and must be published ' do
      designer = create(:designer)
      work = create :standardized_work, :with_iphone6_model, user: designer
      designer_work = create :standardized_work, aasm_state: 'published', user: designer
      my_design_work = create :standardized_work
      designer_works = work.designer_works(5)
      expect(designer_works).to include designer_work
      expect(designer_works).not_to include my_design_work
    end
  end

  describe 'module ProductWorkCode' do
    context 'included' do
      it { should have_one(:work_code) }
    end

    context '#generate_work_code' do
      Given(:work) { create :standardized_work }
      Then { work.work_code.present? }
      And { work.product_code == work.work_code.product_code }
    end
  end

  it '#china_archive_attributes' do
    expect(work.china_archive_attributes).to eq(remote_product_key: work.product.remote_key,
                                                cover_image: nil,
                                                print_image: work.print_image.url,
                                                order_image: work.order_image.try(:url),
                                                name: work.name)
  end

  context 'build previews from print image' do
    let(:work) do
      build(:standardized_work, print_image: print_image,
                                build_previews: build_previews)
    end

    context 'when #build_previews sets to true' do
      let(:build_previews) { true }

      context 'and print image is an image' do
        let(:print_image) { image }

        it 'enqueues' do
          expect(work).to receive(:enqueue_build_previews_by_print_image)
          work.save!
        end
      end

      context 'but print image is not an image' do
        let(:print_image) { nil }

        it 'does not enqueues' do
          expect(work).not_to receive(:enqueue_build_previews_by_print_image)
          work.save!
        end
      end
    end

    context 'when #build_previews sets to false' do
      let(:build_previews) { false }
      let(:print_image) { nil }

      it 'does not enqueues' do
        expect(work).not_to receive(:enqueue_build_previews_by_print_image)
        work.save!
      end
    end
  end

  context 'build print image' do
    let(:work) do
      build(:standardized_work, print_image: print_image,
                                is_build_print_image: is_build_print_image)
    end

    context 'when #is_build_print_image sets to true' do
      let(:is_build_print_image) { true }

      context 'and print image is an image' do
        let(:print_image) { image }

        it 'enqueues' do
          expect(work).to receive(:enqueue_build_print_image)
          work.save!
        end
      end

      context 'but print image is not an image' do
        let(:print_image) { nil }

        it 'does not enqueues' do
          expect(work).not_to receive(:enqueue_build_print_image)
          work.save!
        end
      end
    end

    context 'when #is_build_print_image sets to false' do
      let(:is_build_print_image) { false }
      let(:print_image) { nil }

      it 'does not enqueues' do
        expect(work).not_to receive(:enqueue_build_print_image)
        work.save!
      end
    end
  end

  context 'included QiniuStoreImage' do
    StandardizedWork.const_get(:QiniuStoreImage) == QiniuStoreImage
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

  context 'with promotion' do
    subject { create :standardized_work, :with_iphone6_model, name: 'Jedi Council' }
    it_should_behave_like 'has promotion price'
  end

  describe '#to_ecommerce_tracking' do
    UUID = 'eabc470a-9ed1-4eae-9faa-aed25eec89d4'.freeze
    let(:standardized_work) do
      product = create(:product_model, key: 'PRODUCT_MODEL_KEY')
      create(:standardized_work, uuid: UUID, name: 'NAME', product: product)
    end

    it 'returns hash type data for google analytics' do
      expect(standardized_work.to_ecommerce_tracking).to eq(
        id: UUID,
        name: 'NAME',
        category: 'PRODUCT_MODEL_KEY',
        brand: 'User Name',
        price: 2999.0
      )
    end
  end
end
