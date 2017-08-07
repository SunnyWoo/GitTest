# == Schema Information
#
# Table name: product_models
#
#  id                                        :integer          not null, primary key
#  name                                      :string(255)
#  description                               :text
#  created_at                                :datetime
#  updated_at                                :datetime
#  available                                 :boolean          default(FALSE)
#  slug                                      :string(255)
#  category_id                               :integer
#  key                                       :string(255)
#  dir_name                                  :string(255)
#  placeholder_image                         :string(255)
#  price_tier_id                             :integer
#  design_platform                           :json
#  customize_platform                        :json
#  customized_special_price_tier_id          :integer
#  material                                  :string(255)
#  weight                                    :float
#  enable_white                              :boolean          default(FALSE)
#  auto_imposite                             :boolean          default(FALSE), not null
#  factory_id                                :integer
#  extra_info                                :json
#  aasm_state                                :string(255)
#  positions                                 :json             default(#<ProductModel::Positions:0x007ff27a813688 @ios=1, @android=1, @website=1>)
#  remote_key                                :string(255)
#  watermark                                 :string(255)
#  print_image_mask                          :string(255)
#  craft_id                                  :integer
#  spec_id                                   :integer
#  material_id                               :integer
#  code                                      :string(255)
#  external_code                             :string(255)
#  enable_composite_with_horizontal_rotation :boolean          default(FALSE)
#  create_order_image_by_cover_image         :boolean          default(FALSE)
#  enable_back_image                         :boolean          default(FALSE)
#  profit_id                                 :integer
#

require 'spec_helper'

describe ProductModel do
  it 'FactoryGirl' do
    expect(build(:product_model)).to be_valid
  end

  %i(key slug name).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it { should belong_to(:category) }
  it { should belong_to(:craft) }
  it { should belong_to(:spec) }
  it { should belong_to(:product_material) }
  it { should belong_to(:profit) }

  it { should have_many(:currencies) }
  it { should have_many(:works) }
  it { should have_many(:preview_composers) }
  it { should have_many(:templates) }
  it { should have_many(:product_templates) }

  it { should have_many(:product_option_types) }
  it { should have_many(:option_types) }
  it { should have_many(:variants) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:category_id) }
  it { should validate_uniqueness_of(:key).scoped_to(:category_id) }

  context 'delegate' do
    context 'product_material#code' do
      Given(:product_material) { create :product_material }
      Given(:product) { create :product_model, product_material: product_material }
      Then { product.product_material_code == product_material.code }
    end

    context 'spec#code' do
      Given(:spec) { create :product_spec }
      Given(:product) { create :product_model, spec: spec }
      Then { product.spec_code == spec.code }
    end

    context 'craft#code' do
      Given(:craft) { create :product_craft }
      Given(:product) { create :product_model, craft: craft }
      Then { product.craft_code == craft.code }
    end
  end

  context 'before_validation#generate_code' do
    context 'save with code is nil' do
      Given(:product)  { create :product_model, code: nil }
      Then { product.code.size == 4 }
    end

    context 'save with code is present' do
      Given(:product)  { create :product_model, code: 1234 }
      Then { product.code == '1234' }
    end
  end

  context 'product_code' do
    Given(:spec) { create :product_spec, code: 'T' }
    Given(:craft) { create :product_craft, code: '1' }
    Given(:material) { create :product_material, code: 'PCG' }
    Given(:category_code) { create :product_category_code, code: 'CA' }
    Given(:category) { create :product_category, category_code: category_code }
    Given(:product) do
      create :product_model, spec: spec, craft: craft, product_material: material, code: 'ABCD', category: category
    end
    Then { product.product_code == 'CAPCG1TABCD' }
  end

  it 'has some typed writers' do
    model = build(:product_model)
    expect { model.width = '100' }.to change { model.width }.to(100.0)
    expect { model.height = '100' }.to change { model.height }.to(100.0)
    expect { model.dpi = '100' }.to change { model.dpi }.to(100)
    expect { model.padding_top = '100' }.to change { model.padding_top }.to(100.0)
    expect { model.padding_right = '100' }.to change { model.padding_right }.to(100.0)
    expect { model.padding_bottom = '100' }.to change { model.padding_bottom }.to(100.0)
    expect { model.padding_left = '100' }.to change { model.padding_left }.to(100.0)
    expect { model.ios = '100' }.to change { model.ios }.to(100)
    expect { model.android = '100' }.to change { model.android }.to(100)
    expect { model.website = '100' }.to change { model.website }.to(100)
  end

  context 'check set_platform_position' do
    before do
      @category = create(:product_category)
      1..5.times { create(:product_model, category: @category) }
    end

    it 'check position' do
      product_models = ProductModel.where(category_id: @category.id)
      product_models.first.set_platform_position('ios', 3)
      expect(product_models.size).to eq(5)
      expect(product_models.first.ios).to eq(3)
      position_ids = product_models.order_by('ios').map(&:ios)
      expect(position_ids).to match_array([1, 2, 3, 4, 5])
      product_models.first.set_platform_position('ios', 4)
      expect(product_models.first.ios).to eq(4)
      position_ids = product_models.order_by('ios').map(&:ios)
      expect(position_ids).to match_array([1, 2, 3, 4, 5])
      expect(product_models.platform_order_with_category('ios').map(&:ios)).to match_array([1, 2, 3, 4, 5])
    end
  end

  describe '#customized_special_price' do
    context 'when customized_special_price_tier is nil' do
      it 'returns price' do
        product_model = create(:product_model)
        expect(product_model.customized_special_price('USD')).to eq(product_model.price('USD'))
      end
    end

    context 'when customized_special_price_tier is not' do
      it 'returns price' do
        product_model = create(:product_model, customized_special_price_table: { 'USD' => 60 })
        expect(product_model.customized_special_price('USD')).to eq(60)
      end
    end
  end

  context '#check_platforms' do
    Given(:default_platform) { ProductModel.platforms.stringify_keys }
    Given(:design_platform) { {} }
    Given(:customize_platform) { {} }
    When(:product_model) do
      create(:product_model, design_platform: design_platform, customize_platform: customize_platform)
    end

    context 'has default value' do
      # { "ios" => false, "android" => false, "website" => false }
      Then { product_model.design_platform == default_platform }
      And { product_model.customize_platform == default_platform }
    end

    context 'assignment true' do
      Given(:design_platform) { { 'website' => true } }
      Given(:customize_platform) { { 'ios' => true } }
      Then { product_model.design_platform == default_platform.merge('website' => true) }
      And { product_model.customize_platform == default_platform.merge('ios' => true) }
    end

    context 'allow string true' do
      Given(:design_platform) { { 'website' => 'true' } }
      Given(:customize_platform) { { 'ios' => 'true' } }
      Then { product_model.design_platform == default_platform.merge('website' => true) }
      And { product_model.customize_platform == default_platform.merge('ios' => true) }
    end
  end

  context '#booleanize_hashs' do
    Given(:product_model) { ProductModel.new }
    Given(:input_hash) { { ios: 'true', mobile: 'f', data: true, not_available: [] } }
    When(:result) { product_model.send(:booleanize_hashs, input_hash) }
    Then { result == { ios: true, mobile: false, data: true, not_available: [] } }
  end

  describe '#enqueue_imposite_and_upload' do
    Given(:product_model) { create(:product_model) }
    Given(:order) { create(:paid_order, approved: true) }
    Given(:order_item) { create(:order_item, order: order) }
    Given!(:print_item) { create(:print_item, product: product_model, order_item: order_item) }
    Given(:factory) { create(:factory) }
    Given{ allow(Imposition::Spliter).to receive(:perform_async) }
    When { product_model.enqueue_imposite_and_upload }
    Then { print_item.reload.uploading? }
    And { expect(Imposition::Spliter).to have_received(:perform_async) }
  end

  context 'tags' do
    context 'when add tag' do
      Given(:tag) { create :tag }
      Given(:product_model) { create :product_model }
      Given(:standardized_work) { create :standardized_work, product: product_model }
      When { product_model.tags << tag }
      Then { product_model.tag_ids.include?(tag.id) }
      And { standardized_work.tag_ids.include?(tag.id) }
    end

    context 'when destroy tag' do
      Given(:tag_1) { create :tag }
      Given(:tag_2) { create :tag }
      Given(:product_model) { create :product_model, tag_ids: Tag.all.pluck(:id) }
      Given(:standardized_work) { create :standardized_work, product: product_model }
      Then { standardized_work.tag_ids == Tag.all.pluck(:id) }
      When { product_model.tag_ids = [tag_1.id] }
      Then { product_model.tag_ids == [tag_1.id] }
      And { standardized_work.tag_ids == [tag_1.id] }
    end
  end

  context 'included UploadInventory' do
    ProductModel.const_get(:UploadInventory) == UploadInventory
  end

  context '#sellable_on' do
    before do
      @product1 = create(:product_model, available: true, design_platform:
                         { 'ios' => true, 'android' => false, 'website' => false })
      @product2 = create(:product_model, available: true, design_platform:
                         { 'ios' => false, 'android' => true, 'website' => false })
      @product3 = create(:product_model, available: true, design_platform:
                         { 'ios' => false, 'android' => false, 'website' => true })
    end

    context 'when platform is ios' do
      it 'returns available results' do
        expect(ProductModel.sellable_on('ios')).to match_array([@product1])
      end
    end

    context 'when platform is android' do
      it 'returns available results' do
        expect(ProductModel.sellable_on('android')).to match_array([@product2])
      end
    end

    context 'when platform is website' do
      it 'returns available results' do
        expect(ProductModel.sellable_on('website')).to match_array([@product3])
      end
    end

    context 'when platform is xxx' do
      it 'returns nil' do
        expect(ProductModel.sellable_on('xxx')).to match_array([])
      end
    end
  end

  context '#customizable_on' do
    before do
      @product1 = create(:product_model, available: true, customize_platform:
                         { 'ios' => true, 'android' => false, 'website' => false })
      @product2 = create(:product_model, available: true, customize_platform:
                         { 'ios' => false, 'android' => true, 'website' => false })
      @product3 = create(:product_model, available: true, customize_platform:
                         { 'ios' => false, 'android' => false, 'website' => true })
    end

    context 'when platform is ios' do
      it 'returns available results' do
        expect(ProductModel.customizable_on('ios')).to match_array([@product1])
      end
    end

    context 'when platform is android' do
      it 'returns available results' do
        expect(ProductModel.customizable_on('android')).to match_array([@product2])
      end
    end

    context 'when platform is website' do
      it 'returns available results' do
        expect(ProductModel.customizable_on('website')).to match_array([@product3])
      end
    end

    context 'when platform is xxx' do
      it 'returns nil' do
        expect(ProductModel.customizable_on('xxx')).to match_array([])
      end
    end
  end

  context '#all_on' do
    before do
      @product = create(:product_model, available: true,
                                        design_platform: { 'ios' => true, 'android' => true, 'website' => true },
                                        customize_platform: { 'ios' => true, 'android' => true, 'website' => true })
      @product1 = create(:product_model, available: true,
                                         design_platform: { 'ios' => true, 'android' => false, 'website' => false },
                                         customize_platform: { 'ios' => true, 'android' => false, 'website' => false })
      @product2 = create(:product_model, available: true,
                                         design_platform: { 'ios' => false, 'android' => true, 'website' => false },
                                         customize_platform: { 'ios' => false, 'android' => true, 'website' => false })
      @product3 = create(:product_model, available: true,
                                         design_platform: { 'ios' => false, 'android' => false, 'website' => true },
                                         customize_platform: { 'ios' => false, 'android' => false, 'website' => true })
      @product4 = create(:product_model, available: true,
                                         design_platform: { 'ios' => false, 'android' => false, 'website' => false },
                                         customize_platform: { 'ios' => false, 'android' => false, 'website' => false })
    end

    context 'when platform is ios' do
      it 'returns available results' do
        expect(ProductModel.all_on('ios')).to match_array([@product, @product1])
      end
    end

    context 'when platform is android' do
      it 'returns available results' do
        expect(ProductModel.all_on('android')).to match_array([@product, @product2])
      end
    end

    context 'when platform is website' do
      it 'returns available results' do
        expect(ProductModel.all_on('website')).to match_array([@product, @product3])
      end
    end

    context 'when platform is xxx' do
      it 'returns nil' do
        expect(ProductModel.all_on('xxx')).to match_array([])
      end
    end
  end

  context '#store_on_platform' do
    let!(:product_model) {
      create(:product_model, available: true,
                             design_platform: { 'ios' => true, 'android' => true, 'website' => true },
                             customize_platform: { 'ios' => true, 'android' => true, 'website' => true })
    }
    let!(:unavailable_product_model) {
      create(:product_model, available: false)
    }

    it 'returns available results with platfrom: ios, store: sellable' do
      expect(ProductModel.store_on_platform('ios', 'sellable')).to match_array([product_model])
    end

    it 'returns available results with platfrom: ios, store: customizable' do
      expect(ProductModel.store_on_platform('ios', 'customizable')).to match_array([product_model])
    end

    it 'returns available results with platfrom: ios, store: all' do
      expect(ProductModel.store_on_platform('ios', 'all')).to match_array([product_model])
    end

    it 'raise error with platform: xxx, store: xxx' do
      expect{ ProductModel.store_on_platform('xxx', 'xxx') }.to raise_error
    end
  end

  context 'with promotion' do
    subject { create(:product_model) }
    it_should_behave_like 'has promotion price'
  end

  context '#read_attribute' do
    Given(:product_model) { create(:product_model) }

    ProductModel::EXTRA_INFO_ATTRIBUTES.each do |attr_name|
      Given(:extra_info_attr) { product_model.extra_info[attr_name] }
      When(:value_from_read_attribute) { product_model.read_attribute(attr_name) }
      Then { expect(value_from_read_attribute).to eq(extra_info_attr) }
    end
  end
end
