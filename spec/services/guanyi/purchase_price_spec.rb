require 'spec_helper'

describe Guanyi::PurchasePrice do
  Given(:purchase_price) { Guanyi::PurchasePrice.new }
  Given(:rule) do
    {
      'case' => 'case_sublimate',
      'canvas' => {
        '15x15cm_canvas_cn' => 'canvas_15x15',
        '45x30cm_canvas_cn' => 'canvas_30x30_30x45',
        '30x30cm_canvas_cn' => 'canvas_30x30_30x45'
      }
    }.with_indifferent_access
  end
  Given(:fee) do
    {
      'case_sublimate' => {
        0 => 20.2,
        101 => 17.1,
        501 => 15.0,
        1001 => 12.9
      }
    }.with_indifferent_access
  end
  Given(:categories_sell_count) do
    {
      'case_sublimate' => 1
    }.with_indifferent_access
  end

  context '#price' do
    before do
      purchase_price.redis.set('case_sublimate', '15.0')
      allow(purchase_price).to receive(:mapping_category_key).and_return('case_sublimate')
    end
    Then { purchase_price.price('work') == '15.0' }
  end

  context '#collect_categories_price' do
    before do
      allow(purchase_price).to receive(:categories_sell_count).and_return(categories_sell_count)
      allow(purchase_price).to receive(:mapping_price_key).and_return(501)
    end
    When { purchase_price.send(:collect_categories_price) }
    Then { purchase_price.redis.get('case_sublimate') == '15.0' }
  end

  context '#collect_categories_sell_count' do
    Given(:order) { create :order }
    Given!(:order_item) { create :order_item, order: order }
    before do
      purchase_price.categories_sell_count = categories_sell_count
      allow(purchase_price).to receive(:orders).and_return(Order.all)
      allow(purchase_price).to receive(:mapping_category_key).and_return('case_sublimate')
    end
    When { purchase_price.send(:collect_categories_sell_count) }
    Then { purchase_price.categories_sell_count == { 'case_sublimate' => 3 } }
  end

  context '#mapping_category_key' do
    context 'when rule[category_key].is_a? not Hash' do
      before { allow(purchase_price).to receive(:rule).and_return(rule) }
      Given(:category) { create :product_category, key: 'case' }
      Given(:product) { create :product_model, category: category }
      Given!(:work) { create :work, product: product }
      Given(:category_key) { purchase_price.send(:mapping_category_key, work) }
      Then { category_key == 'case_sublimate' }
    end

    context 'when rule[category_key].is_a? Hash' do
      before { allow(purchase_price).to receive(:rule).and_return(rule) }
      Given(:category) { create :product_category, key: 'canvas' }
      Given(:product) { create :product_model, category: category, key: '15x15cm_canvas_cn' }
      Given!(:work) { create :work, product: product }
      Given(:category_key) { purchase_price.send(:mapping_category_key, work) }
      Then { category_key == 'canvas_15x15' }
    end
  end

  context '#mapping_price_key' do
    context 'sell_count included in keys' do
      Given(:price_key) { purchase_price.send(:mapping_price_key, [0, 101, 501, 1000], 101) }
      Then { price_key == 101 }
    end

    context 'sell_count is bigger than max key' do
      Given(:price_key) { purchase_price.send(:mapping_price_key, [0, 101, 501, 1000], 2000) }
      Then { price_key == 1000 }
    end

    context 'sell_count is between keys' do
      Given(:price_key) { purchase_price.send(:mapping_price_key, [0, 101, 501, 1000], 600) }
      Then { price_key == 501 }
    end
  end
end
