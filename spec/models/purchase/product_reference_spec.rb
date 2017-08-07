# == Schema Information
#
# Table name: purchase_product_references
#
#  id          :integer          not null, primary key
#  product_id  :integer
#  category_id :integer
#  b2c_count   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe Purchase::ProductReference, type: :model do
  it 'FactoryGirl' do
    expect(build(:purchase_category)).to be_valid
  end

  context 'validation' do
    it { should belong_to(:product) }
    it { should belong_to(:category) }
  end

  context '.increment_b2c_count' do
    Given(:product) { create :product_model }
    Given(:work) { create :work, product: product }
    Given(:order_item) { create :order_item, quantity: 2, itemable: work }
    Given!(:product_reference) { create :purchase_product_reference, product_id: product.id }

    When { Purchase::ProductReference.increment_b2c_count(order_item) }
    Then { product_reference.reload.b2c_count == 2 }
  end

  context '.clear_history' do
    Given(:product_reference) { create :purchase_product_reference, b2c_count: 2 }
    before { product_reference.price = 20 }

    When { Purchase::ProductReference.clear_history }
    Then { product_reference.reload.b2c_count == 0 }
    And { product_reference.price.value.nil? }
  end

  context '#purchase_price' do
    context 'value in redis' do
      Given(:price) { Redis::Value.new(nil) }
      Given(:product_reference) { create :purchase_product_reference }
      before do
        price.value = '11.11'
        allow(product_reference).to receive(:price).and_return(price)
      end

      Then { product_reference.purchase_price == '11.11' }
    end

    context 'value by calculate' do
      Given(:category) { create :purchase_category }
      Given(:product_reference) { create :purchase_product_reference, category: category }
      before { allow(category).to receive(:purchase_price).and_return('22.22') }

      Then { product_reference.purchase_price == '22.22' }
      And { product_reference.price == '22.22' }
    end
  end
end
