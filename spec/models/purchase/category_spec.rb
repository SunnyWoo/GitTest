# == Schema Information
#
# Table name: purchase_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Purchase::Category, type: :model do
  it 'FactoryGirl' do
    expect(build(:purchase_category)).to be_valid
  end

  context 'validation' do
    it { should validate_presence_of(:name) }
  end

  context '#product_ids=' do
    Given(:product_model_1) { create :product_model }
    Given(:product_model_2) { create :product_model }
    Given(:purchase_category) { create :purchase_category }
    Given!(:product_reference) { create :purchase_product_reference, product: product_model_1, category: purchase_category }

    When { purchase_category.product_ids = product_model_2.id }
    Then { purchase_category.product_references.pluck(:product_id) == [product_model_2.id] }
  end

  context '#product_ids' do
    Given(:product_model) { create :product_model }
    Given(:purchase_category) { create :purchase_category }
    Given!(:product_reference) { create :purchase_product_reference, product: product_model, category: purchase_category }

    Then { purchase_category.product_ids == [product_model.id] }
  end

  context '#purchase_price' do
    Given(:purchase_category) { create :purchase_category }
    Given!(:product_reference) { create :purchase_product_reference, category: purchase_category, b2c_count: 10 }
    Given!(:product_tier_1) { create :purchase_price_tier, category: purchase_category, count_key: 0, price: 100 }
    Given!(:product_tier_2) { create :purchase_price_tier, category: purchase_category, count_key: 100, price: 50 }

    Then { purchase_category.purchase_price == product_tier_1.price }
  end
end
