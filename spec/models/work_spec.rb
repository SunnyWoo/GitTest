# == Schema Information
#
# Table name: works
#
#  id                      :integer          not null, primary key
#  name                    :string(255)
#  description             :string(255)
#  created_at              :datetime
#  updated_at              :datetime
#  cover_image             :string(255)
#  work_type               :integer          default(1)
#  finished                :boolean          default(FALSE)
#  feature                 :boolean          default(FALSE)
#  uuid                    :string(255)
#  print_image             :string(255)
#  model_id                :integer
#  artwork_id              :integer
#  image_meta              :json
#  slug                    :string(255)
#  impressions_count       :integer          default(0)
#  ai                      :string(255)
#  pdf                     :string(255)
#  price_tier_id           :integer
#  attached_cover_image_id :integer
#  template_id             :integer
#  deleted_at              :datetime
#  user_type               :string(255)
#  user_id                 :integer
#  application_id          :integer
#  product_template_id     :integer
#  cradle                  :integer          default(0)
#  share_text              :text
#  variant_id              :integer
#

require 'spec_helper'

describe Work do
  it_behaves_like 'an itemable'
  it_behaves_like 'acts_as_taggable'

  it 'FactoryGirl' do
    expect(create(:work)).to be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:product) }
  it { should belong_to(:product_template) }

  let(:work) { create(:work) }
  let(:work_with_cover_image) { create(:work, :with_cover_image) }
  it { expect(work.cover_image).to be_truthy }
  it { expect(work.product).to be_truthy }
  it { expect(work.original_prices).to eq(work.product.prices) }

  it { should define_enum_for(:cradle).with(Work::CRADLE_TYPES) }

  context 'build layer' do
    it 'init' do
      layer = work_with_cover_image.build_layer
      expect(layer.orientation).to eq(0.0)
      expect(layer.scale_x).to eq(0.5)
      expect(layer.scale_y).to eq(0.5)
      expect(layer.position_x).to eq(0.0)
      expect(layer.position_y).to eq(0.0)
      expect(layer.layer_type).to eq('photo')
      expect(layer.transparent).to eq(1.0)
      expect(layer.image).not_to be_nil
      expect(layer.filtered_image).not_to be_nil
    end

    it 'update' do
      2.times { work_with_cover_image.build_layer }
      expect(work_with_cover_image.reload.layers.length).to eq(1)
    end
  end

  context 'paper_trail' do
    it 'version check' do
      with_versioning do
        work = create :work
        first_version_size = work.versions.size
        expect(first_version_size).not_to eq 0
        work.update_attribute(:name, 'paper trail')
        expect(work.versions.size).to be > first_version_size
      end
    end
  end

  describe '#archived_attributes' do
    it 'returns attributes that can be used to build archived work' do
      work = create(:work).tap(&:build_layer)
      work_archived_attributes = work.archived_attributes
      work_order_image = work_archived_attributes.delete(:work_order_image)
      expect(work_archived_attributes).to eq(
        model_id: work.model_id,
        variant_id: work.variant_id,
        cover_image: work.cover_image.file,
        application_id: work.application_id,
        layers_attributes: work.layers.map(&:archived_attributes),
        user_type: work.user_type,
        user_id: work.user_id,
        name: work.name,
        product_code: work.product_code,
        product_template_id: work.product_template_id
      )
      expect(work_order_image.file).to eq(work.order_image.file.file)
    end
  end

  describe '#create_archive' do
    it 'creates archived work by archived attributes' do
      work = create(:work, :with_cover_image).tap(&:build_layer)
      archived_work = work.create_archive

      expect(archived_work).to be_persisted
      expect(archived_work.layers.first).to be_persisted
    end

    it 'creates archived work with mask layer correctly' do
      work = create(:work, :with_cover_image).tap(&:build_layer)
      create(:layer, work: work, layer_type: 'mask', masked_layers: work.layers, position: 2)
      work.reload
      archived_work = work.create_archive

      expect(archived_work).to be_persisted
      expect(archived_work.layers.first).to be_persisted
      expect(archived_work.layers.size).to eq(1)
      expect(archived_work.layers[0]).to be_mask
      expect(archived_work.layers[0].masked_layers).to be_present
    end
  end

  describe '#last_archive' do
    it 'returns a new archive' do
      work = create(:work).tap(&:build_layer)
      expect(work).to receive(:create_archive)
      work.last_archive
    end
  end

  describe '#elasticsearch', elasticsearch: true do
    context 'search by id' do
      it 'return true' do
        expect(Work.search_by_id(work.id).results.total).to eq(0)
        work = create(:work, :is_public)
        work.__elasticsearch__.index_document
        # for elasticsearch add index
        Work.__elasticsearch__.refresh_index!
        expect(Work.search_by_id(work.id).results.total).to eq(1)
      end
    end

    context 'after destroy' do
      it 'return true when index is delete' do
        work = create(:work, :is_public)
        work.__elasticsearch__.index_document
        Work.__elasticsearch__.refresh_index!
        work.__elasticsearch__.delete_document
        work.destroy
      end
    end
  end

  describe '#price_in_currency' do
    context 'for a private work' do
      context 'when model customized_special_price_tier is nil' do
        it 'returns model price' do
          product_model = create(:product_model)
          work = create(:work, model: product_model)
          expect(work.price_in_currency('USD')).to eq(product_model.price('USD'))
        end
      end

      context 'when model customized_special_price_tier is not' do
        it 'returns customized special price' do
          product_model = create(:product_model, customized_special_price_table: { 'USD' => 60 })
          work = create(:work, model: product_model)
          expect(work.price_in_currency('USD')).to eq(60)
        end
      end
    end

    context 'for a public work' do
      context 'when model customized_special_price_tier is nil' do
        it 'returns model price' do
          product_model = create(:product_model)
          work = create(:work, :is_public, model: product_model)
          expect(work.price_in_currency('USD')).to eq(product_model.price('USD'))
        end
      end

      context 'when model customized_special_price_tier is not' do
        it 'returns model price' do
          product_model = create(:product_model, customized_special_price_table: { 'USD' => 60 })
          work = create(:work, :is_public, model: product_model)
          expect(work.price_in_currency('USD')).to eq(product_model.price('USD'))
        end
      end
    end
  end

  describe 'after update' do
    it 'touchs every order item' do
      work = create(:work)
      order_item = create(:order_item, itemable: work)
      work.update(slug: 'hello')
      expect(order_item.updated_at).not_to eq(order_item.reload.updated_at)
    end
  end

  describe '#series_works' do
    it 'returns the works with the same name and must be public' do
      work = create :work, :with_iphone6_model
      series_work = create :work, :with_ipad_air2_model
      my_design_work = create :work
      series_works = work.series_works(5)
      expect(series_works).to include series_work
      expect(series_works).not_to include my_design_work
    end
  end

  describe '#designer_works' do
    it 'returns the works belonging to the same designer and must be public ' do
      designer = create(:designer)
      work = create :work, :with_iphone6_model, user: designer
      designer_work = create :work, work_type: 'is_public', user: designer
      my_design_work = create :work
      designer_works = work.designer_works(5)
      expect(designer_works).to include designer_work
      expect(designer_works).not_to include my_design_work
    end
  end

  describe '#image' do
    Given(:work) { create(:work) }

    context 'uploads to work directly' do
      Then { work.cover_image.model == work }
    end

    it { should have_attachment(:cover_image) }
  end

  describe '#previews' do
    Given(:work) { create(:work) }
    Given { expect(work).to receive(:destroy_previews).and_call_original }
    When { work.update(perform_destroy_previews: true) }
    Then {}
  end

  describe 'WorkSaleCount' do
    it '#set_sale_count_limit' do
      limit = '999'
      work.set_sale_count_limit(limit)
      expect(work.sale_count_limit).to eq(limit)
    end

    it '#incr_sale_count' do
      11.times { work.incr_sale_count }
      expect(work.sale_count).to eq('11')
    end
  end

  describe 'module ProductWorkCode' do
    context 'included' do
      it { should have_one(:work_code) }
    end

    context '#generate_work_code' do
      Given(:work) { create :work }
      Then { work.work_code.present? }
      And { work.product_code == work.work_code.product_code }
    end
  end

  context 'included QiniuStoreImage' do
    Work.const_get(:QiniuStoreImage) == QiniuStoreImage
  end

  context '#build_print_image' do
    let(:layer) { create(:layer, layer_type: 'fake') }
    let(:work_with_layers) { create(:work, layers: [layer]) }

    it 'return nil when layers is empty' do
      expect(work.layers.count).to eq(0)
      expect(work.print_image.present?).to be_falsey
      expect(work.build_print_image).to be_truthy
      expect(work.print_image.present?).to be_truthy
    end

    it 'return true when layers is not empty' do
      expect(work_with_layers.layers.count).to eq(1)
      expect(work_with_layers.print_image.present?).to be_falsey
      expect(work_with_layers.build_print_image).to be_truthy
      expect(work_with_layers.print_image.present?).to be_truthy
    end
  end

  context 'with promotion' do
    subject { create(:work) }
    it_should_behave_like 'has promotion price'
  end

  context 'build work with promotion' do
    subject { build(:work) }
    it_should_behave_like 'has promotion price'
  end

  context 'enqueue_build_previews' do
    context 'when create_order_image_by_cover_image is false' do
      Given(:product) { create :product_model }
      context 'increases PreviewBuilder jobs to create order_image by cover_image with which stored' do
        Given!(:work) { create :work, :with_cover_image, product: product }
        Then { assert_equal 1, PreviewsBuilder.jobs.size }
        And { PreviewsBuilder.jobs.last['args'] == [work.to_gid.to_s, 'cover_image', false] }
        context 'increases PreviewBuilder jobs to create order_image by print_image with which stored' do
          When { work.build_print_image }
          Then { assert_equal 2, PreviewsBuilder.jobs.size }
          And { PreviewsBuilder.jobs.last['args'] == [work.to_gid.to_s, 'print_image', true] }
        end
      end
    end

    context 'when create_order_image_by_cover_image is true' do
      Given(:product) { create :product_model, create_order_image_by_cover_image: true }
      context 'increases PreviewBuilder jobs to create order_image by cover_image with which stored' do
        Given!(:work) { create :work, :with_cover_image, product: product }
        Then { assert_equal 1, PreviewsBuilder.jobs.size }
        And { PreviewsBuilder.jobs.last['args'] == [work.to_gid.to_s, 'cover_image', false] }
        context 'does not increase PreviewBuilder jobs to create order_image by print_image with which stored' do
          When { work.build_print_image }
          Then { assert_equal 1, PreviewsBuilder.jobs.size }
        end
      end
    end
  end

  describe '#to_ecommerce_tracking' do
    UUID = 'eabc470a-9ed1-4eae-9faa-aed25eec89d4'.freeze
    let(:work) do
      product_model = create(:product_model, key: 'PRODUCT_MODEL')
      create(:work, uuid: UUID, model_id: product_model.id)
    end

    it 'returns hash type data for google analytics' do
      expect(work.to_ecommerce_tracking).to eq(
        id: UUID,
        name: 'work name',
        category: 'PRODUCT_MODEL',
        brand: 'User',
        price: 2999.0
      )
    end
  end
end
