# == Schema Information
#
# Table name: product_categories
#
#  id               :integer          not null, primary key
#  key              :string(255)
#  available        :boolean          default(FALSE), not null
#  created_at       :datetime
#  updated_at       :datetime
#  position         :integer
#  category_code_id :string(255)
#  image            :string(255)
#  positions        :json             default(#<ProductCategory::Positions:0x007ff2747e00e0 @ios=1, @android=1, @website=1>)
#

require 'rails_helper'

RSpec.describe ProductCategory, type: :model do
  it 'FactoryGirl' do
    expect(build(:product_category)).to be_valid
  end

  it_behaves_like 'acts_as_taggable'

  it { should validate_uniqueness_of(:key) }
  it { should validate_presence_of(:key) }

  it { should belong_to(:category_code) }
  it { should have_many(:products) }
  it { should have_many(:available_products) }
  it { should have_many(:available_website_product_works) }

  it { should validate_presence_of(:key) }
  it { should validate_uniqueness_of(:key) }

  context 'delegate' do
    context 'category_code#code' do
      Given(:category_code) { create :product_category_code, code: 'CA' }
      Given(:category) { create :product_category, category_code: category_code }
      Then { category.code == category_code.code }
    end
  end

  describe '#friendly_name' do
    Given(:new_category) { ProductCategory.new }
    Given(:category) { create(:product_category) }
    context 'when key is blank' do
      When(:friendly_name) { new_category.friendly_name }
      Then { friendly_name == 'All' }
    end

    context 'normal category' do
      When(:friendly_name) { category.friendly_name }
      Then { friendly_name == category.name }
    end
  end

  describe '#work_list' do
    Given(:new_category) { ProductCategory.new }
    Given(:category) { create(:product_category) }
    context 'when key is blank' do
      When(:work_list) { new_category.work_list(ProductModel.new) }
      Then { work_list == StandardizedWork.with_available_product.with_sellable_on_product('website').is_public }
    end

    context 'normal category' do
      Given(:model) { create(:product_model) }
      When(:work_list) { category.work_list(model) }
      Then { work_list == model.works.is_public }
    end
  end

  describe '#all?' do
    context 'key is blank' do
      Given(:new_category) { ProductCategory.new }
      When(:all?) { new_category.all? }
      Then { all? }
    end
  end

  context 'scope#with_sellable_on_product' do
    Given!(:category1) { create :product_category, available: false }
    Given!(:category2) { create :product_category, available: true }
    Given!(:category3) { create :product_category, available: true }
    context 'website' do
      Given!(:product1) do
        create :product_model, category: category2, available: true,
                               design_platform: { 'ios' => false, 'android' => false, 'website' => true }
      end
      Given!(:product2) do
        create :product_model, category: category2, available: false,
                               design_platform: { 'ios' => false, 'android' => false, 'website' => true }
      end
      Given!(:product3) do
        create :product_model, category: category3, available: true,
                               design_platform: { 'ios' => false, 'android' => false, 'website' => false }
      end
      Then { ProductCategory.with_sellable_on_product('website') == [category2] }
    end

    context 'android' do
      Given!(:product1) do
        create :product_model, category: category2, available: true,
                               design_platform: { 'ios' => false, 'android' => false, 'website' => true }
      end
      Given!(:product2) do
        create :product_model, category: category2, available: false,
                               design_platform: { 'ios' => false, 'android' => false, 'website' => true }
      end
      Given!(:product3) do
        create :product_model, category: category3, available: true,
                               design_platform: { 'ios' => false, 'android' => true, 'website' => false }
      end
      Then { ProductCategory.with_sellable_on_product('android') == [category3] }
    end

    context 'ios' do
      Given!(:product1) do
        create :product_model, category: category2, available: true,
                               design_platform: { 'ios' => true, 'android' => false, 'website' => false }
      end
      Given!(:product2) do
        create :product_model, category: category2, available: false,
                               design_platform: { 'ios' => true, 'android' => false, 'website' => false }
      end
      Given!(:product3) do
        create :product_model, category: category3, available: true,
                               design_platform: { 'ios' => true, 'android' => true, 'website' => false }
      end
      Then { expect(ProductCategory.with_sellable_on_product('ios')).to match_array([category3, category2]) }
    end
  end

  context 'ProductCategory.category_list' do
    Given!(:category1) { create :product_category, available: false }
    Given(:category2) { create :product_category, available: true }
    Given(:category3) { create :product_category, available: true }
    Given!(:product1) do
      create :product_model, category: category2, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => true }
    end
    Given!(:product2) do
      create :product_model, category: category2, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => true }
    end
    Given!(:product3) do
      create :product_model, category: category3, available: true,
                             design_platform: { 'ios' => false, 'android' => false, 'website' => false }
    end
    context 'category_list' do
      Then { ProductCategory.category_list.map(&:friendly_name) == ['All', category2.name] }
    end
  end

  context 'tags' do
    context 'when add tag' do
      Given(:tag) { create :tag }
      Given(:category) { create :product_category }
      Given(:product) { create :product_model, category: category }
      When { category.tags << tag }
      Then { category.tag_ids.include?(tag.id) }
      And { product.tag_ids.include?(tag.id) }
    end

    context 'when destroy tag' do
      Given(:tag_1) { create :tag }
      Given(:tag_2) { create :tag }
      Given(:category) { create :product_category, tag_ids: Tag.all.pluck(:id) }
      Given(:product) { create :product_model, category: category }
      Then { product.tag_ids = Tag.all.pluck(:id) }
      When { category.tag_ids =  [tag_1.id] }
      Then { category.tag_ids == [tag_1.id] }
      And { product.tag_ids == [tag_1.id] }
    end
  end

  let(:category) { create :product_category }

  context 'when image' do
    context 'is not null' do
      before do
        category.update(image: File.open(Rails.root.join('spec/photos/test.jpg')))
      end
      it 'get image url not to be nil' do
        expect(category.image.url).not_to be(nil)
        expect(category.image.s80.url).not_to be(nil)
        expect(category.image.s160.url).not_to be(nil)
      end
    end

    context 'is null' do
      it 'get image url is nil' do
        expect(category.image.url).to be(nil)
        expect(category.image.s80.url).to be(nil)
        expect(category.image.s160.url).to be(nil)
      end
    end
  end

  context 'check positions' do
    Given!(:category) { create(:product_category, positions: { ios: 1, android: 3, website: 2 }) }
    Given!(:category2) { create(:product_category, positions: { ios: 2, android: 2, website: 1 }) }
    Given!(:category3) { create(:product_category, positions: { ios: 3, android: 1, website: 3 }) }
    Then { ProductCategory.order_by('ios').first.id == category.id }
    And { ProductCategory.order_by('android').first.id == category3.id }
    And { ProductCategory.order_by('website').first.id == category2.id }
  end
end
