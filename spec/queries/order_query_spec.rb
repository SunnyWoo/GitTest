require 'spec_helper'

describe OrderQuery do
  context 'using default relation scope' do
    Given(:query) { OrderQuery.new }
    Given(:result) { query.execute }
    Given(:c1) { create :product_category }
    Given(:c2) { create :product_category }
    Given(:c4) { create :product_category }
    Given(:p1) { create :product_model, category: c1 }
    Given(:p2) { create :product_model, category: c2 }
    Given(:p3) { create :product_model, category: c1 }
    Given(:p4) { create :product_model, category: c4 }
    Given(:work1) { create :standardized_work, product: p1 }
    Given(:work2) { create :standardized_work, product: p2 }
    Given(:work3) { create :work, product: p3 }
    Given(:work4) { create :standardized_work, product: p4 }
    Given!(:order1){
      create :order, order_items: [
        create(:order_item, itemable: work1),
        create(:order_item, itemable: work2),
        create(:order_item, itemable: work3)
      ]
    }
    Given!(:order2){
      create :order, order_items: [
        create(:order_item, itemable: work2),
        create(:order_item, itemable: work3)
      ]
    }
    Given!(:order3){
      create :order, order_items: [
        create(:order_item, itemable: work2)
      ]
    }
    Given!(:order4){
      create :order, order_items: [
        create(:order_item, itemable: work2),
        create(:order_item, itemable: work4)
      ]
    }

    context '#by_categories' do
      context 'called with one category assigned' do
        When { query.by_categories(c1) }
        Then { expect(result).to match_array([order1, order2]) }
      end

      context 'called with multiple categories assigned' do
        When { query.by_categories([c1, c4]) }
        Then { expect(result).to match_array([order1, order2, order4]) }
      end

      context 'called with category ids' do
        When { query.by_categories([c1.id, c4.id]) }
        Then { expect(result).to match_array([order1, order2, order4]) }
      end
    end

    describe '#by_products' do
      context 'one product' do
        When { query.by_products(p3) }
        Then { expect(result).to match_array([order1, order2]) }
      end

      context 'multiple products' do
        When { query.by_products(p1, p4) }
        Then { expect(result).to match_array([order1, order4]) }
      end
    end

    describe '#by_standardized_works' do
      context 'one works' do
        When { query.by_standardized_works(work2) }
        Then { expect(result).to match_array([order1, order2, order3, order4]) }
      end

      context 'multiple works' do
        When { query.by_standardized_works(work1.id, work4.id) }
        Then { expect(result).to match_array([order1, order4]) }
      end
    end
  end

  context 'assigned relation scope' do
    Given(:query) { OrderQuery.new(Order.paid) }
    Given!(:order1){ create :order, aasm_state: :paid }
    Given!(:order2){ create :order, aasm_state: :pending }
    Given!(:order3){ create :order, aasm_state: :paid }
    Then { expect(query.execute).to match_array([order1, order3]) }
  end
end
