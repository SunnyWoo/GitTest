require 'spec_helper'

describe PriceCalculator do
  subject(:calculator) { PriceCalculator.new(order) }

  let(:order) do
    create(:order).tap(&:reload).tap(&:save)
  end

  let(:promotion) { create :standardized_work_promotion }

  before do
    create_basic_currencies
  end

  context 'when gives an order' do
    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(99.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(99.9)
    end

    it 'calculates correct amount with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 9 })
      order.order_items = [create(:order_item, itemable: itemable)]
      expect(calculator.subtotal).to eq(9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(9)
    end
  end

  context 'when gives an order with many items' do
    before do
      order.order_items.first.update(quantity: 3)
      order.save
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(299.7) # 99.9 * 3
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(299.7) # 99.9 * 3
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(299.7) # 99.9 * 3
    end

    it 'calculates correct amount with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 9 })
      order.order_items = [create(:order_item, itemable: itemable, quantity: 3)]
      expect(calculator.subtotal).to eq(9 * 3)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(9 * 3)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(9 * 3)
    end

    context 'calculates correct amount with order item adjustments values' do
      it 'calculates only for adjustment target type for special' do
        order.order_items.first.adjustments.build source: promotion, event: 'apply', value: -60, quantity: 3
        expect(calculator.subtotal).to eq(299.7 - (20 * 3))
      end
    end

    context 'calculates correct amount with order item adjustments values' do
      it 'calculates only for adjustment target type for special' do
        order.order_adjustments.build source: promotion, event: 'apply', value: -100
        expect(calculator.subtotal).to eq(299.7)
        expect(calculator.discount).to eq(100)
        expect(calculator.price).to eq(299.7 - 100)
      end
    end

    it 'calculates correct amount with both order_item as well as order adjustment' do
      order.order_items.first.adjustments.build source: promotion, event: 'apply', value: -60, quantity: 3
      order.order_adjustments.build source: promotion, event: 'apply', value: -100, quantity: 1
      expect(calculator.subtotal).to eq(299.7 - (20 * 3))
      expect(calculator.discount).to eq(100)
      expect(calculator.price).to eq(139.7)
    end

    it 'returns 0 with item_level adjustments_value exceeding the sum of order items price' do
      order.order_items.first.adjustments.build source: promotion, event: 'apply', value: -100_000
      expect(calculator.subtotal).to eq(0)
    end

    it 'returns 0 with both order and item adjustments_value exceeding the sum of order items price' do
      order.order_items.first.adjustments.build source: promotion, event: 'apply', value: -50_000
      order.order_adjustments.build source: promotion, event: 'apply', value: -50_000
      expect(calculator.subtotal).to eq(0)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(0)
    end
  end

  context 'when gives an order with fixed coupon' do
    before do
      order.coupon = create(:coupon)
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(94.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(94.9)
    end

    it 'calculates correct amount with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 9 })
      order.order_items = [create(:order_item, itemable: itemable)]
      expect(calculator.subtotal).to eq(9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(9 - 5)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(4)
    end

    it 'calculates correct amount with item level adjustment' do
      order.order_items.first.adjustments.create source: promotion, target: 'special', event: 'apply', value: -20
      expect(calculator.subtotal).to eq(79.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(74.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(74.9)
    end

    it 'calculates correct amount with order level adjustment' do
      order.order_adjustments.build source: promotion, event: 'apply', value: -20, quantity: 1
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(20 + 5) # order level + coupon
      expect(calculator.price).to eq(74.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(74.9)
    end
  end

  context 'when gives an order with percentage coupon' do
    before do
      order.coupon = create(:percentage_coupon)
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount.round(2)).to eq((99.9 * 0.2).round(2))
      expect(calculator.price.round(2)).to eq((99.9 * 0.8).round(2))
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq((99.9 * 0.8).round(2))
    end

    it 'calculates correct amount with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 9 })
      order.order_items = [create(:order_item, itemable: itemable)]
      expect(calculator.subtotal).to eq(9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(9 * 0.2)
      expect(calculator.price).to eq(9 * 0.8)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(9 * 0.8)
    end

    it 'calculates correct amount with item level adjustment' do
      order.order_items.first.adjustments.create source: promotion, target: 'special', event: 'apply', value: -20
      expect(calculator.subtotal).to eq(79.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount.round(2)).to eq((79.9 * 0.2).round(2))
      expect(calculator.price.round(2)).to eq((79.9 * 0.8).round(2))
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq((79.9 * 0.8).round(2))
    end

    it 'calculates correct amount with order level adjustment' do
      order.order_adjustments.build source: promotion, event: 'apply', value: -20, quantity: 1
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount.round(2)).to eq((99.9 * 0.2 + 20).round(2))
      expect(calculator.price.round(2)).to eq((99.9 * 0.8 - 20).round(2))
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq((99.9 * 0.8 - 20).round(2))
    end

    it 'calculates correct amount with order level adjustment' do
      order.order_items.first.adjustments.build source: promotion, event: 'apply', value: -20, quantity: 1
      order.order_adjustments.build source: promotion, event: 'apply', value: -20
      expect(calculator.subtotal).to eq(79.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount.round(2)).to eq((79.9 * 0.2 + 20).round(2))
      expect(calculator.price.round(2)).to eq((79.9 * 0.8 - 20).round(2))
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq((79.9 * 0.8 - 20).round(2))
    end
  end

  context 'when gives an order with fixed coupon that threshold >= 100' do
    before do
      order.coupon = create(:coupon, condition: 'simple',
                                     coupon_rules: [create(:threshold_rule, threshold_price_table: { 'USD' => 100 } )])
    end

    it 'raises error' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect { calculator.discount }.to raise_error(CannotUseCouponError)
      expect { calculator.price }.to raise_error(CannotUseCouponError)
      expect(calculator.refund).to eq(0)
      expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
    end

    it 'raises error with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 9 })
      order.order_items = [create(:order_item, itemable: itemable)]
      expect(calculator.subtotal).to eq(9)
      expect(calculator.shipping).to eq(0)
      expect { calculator.discount }.to raise_error(CannotUseCouponError)
      expect { calculator.price }.to raise_error(CannotUseCouponError)
      expect(calculator.refund).to eq(0)
      expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
    end
  end

  context 'when gives an order with fixed coupon that threshold >= 50' do
    before do
      order.coupon = create(:coupon, condition: 'simple',
                                     coupon_rules: [create(:threshold_rule, threshold_price_table: { 'USD' => 50 })])
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(94.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(94.9)
    end

    it 'calculates correct amount with special priced work' do
      itemable = create(:work, price_table: { 'USD' => 200 })
      order.order_items = [create(:order_item, itemable: itemable)]
      expect(calculator.subtotal).to eq(200)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(200 - 5)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(195) # 200 - 5
    end

    it 'calculates correct amount with adjustments' do
      order.order_items.first.adjustments.create source: promotion, target: 'special', event: 'apply', value: -20
      expect(calculator.subtotal).to eq(79.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(74.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(74.9)
    end

    it 'raise error amount with adjustments value made subtotal lower than threshold' do
      order.order_items.first.adjustments.create source: promotion, target: 'special', event: 'apply', value: -60
      expect(calculator.subtotal).to eq(39.9)
      expect(calculator.shipping).to eq(0)
      expect { calculator.discount }.to raise_error(CannotUseCouponError)
      expect { calculator.price }.to raise_error(CannotUseCouponError)
      expect(calculator.refund).to eq(0)
      expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
    end
  end

  context 'when gives an order with fixed coupon that only for some product models' do
    context 'and apply count limit is 1' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_model_rule, product_model_ids: [order.order_items.first.itemable.product.id])],
                                       apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5)
        expect(calculator.price).to eq(99.9 * 4 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(394.6) # 99.9 * 4 - 5
      end

      it 'calculates correct amount with item level adjustments' do
        order.order_items.first.adjustments.build source: promotion, target: 'special', event: 'apply', value: -40, quantity: 2
        expect(calculator.subtotal).to eq(99.9 * 2 + 79.9 * 2)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5)
        expect(calculator.price).to eq(99.9 * 2 + 79.9 * 2 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(99.9 * 2 + 79.9 * 2 - 5)
      end

      it 'calculates correct amount with order adjustments' do
        order.order_adjustments.build source: promotion, target: 'special', event: 'apply', value: -20, quantity: 1
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(20 + 5) # order_level + coupon
        expect(calculator.price).to eq(99.9 * 4 - 20 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(99.9 * 4 - 20 - 5)
      end

      it 'calculates correct amount with both item and order adjustments' do
        item = order.order_items.first
        item.adjustments.build source: promotion, event: 'apply', value: -40, quantity: 2 # -20 each item
        order.order_adjustments.build source: promotion, adjustable: order, event: 'apply', value: -20, quantity: 1

        expect(calculator.subtotal).to eq(99.9 * 2 + 79.9 * 2)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(20 + 5) # order level + coupon
        expect(calculator.price).to eq(99.9 * 2 + 79.9 * 2 - 25)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(99.9 * 2 + 79.9 * 2 - 20 - 5)
      end
    end

    context 'and apply count limit is 1 and discount > item.price' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_model_rule, product_model_ids: [order.order_items.first.itemable.product.id])],
                                       apply_count_limit: 1,
                                       price_table: { 'USD' => 200 })
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9)
        expect(calculator.price).to eq(299.7) # 99.9 * 4 - 99.9
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(299.7) # 99.9 * 4 - 99.9
      end
    end

    context 'and apply count limit is no limit' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_model_rule, product_model_ids: [order.order_items.first.itemable.product.id])],
                                       apply_count_limit: -1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 5 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(389.6) # 99.9 * 4 - 5 * 2
      end

      it 'limits to not discount more than model price' do
        order.coupon = create(:coupon, price_table: { 'USD' => 999 },
                                       condition: 'simple',
                                       coupon_rules: [create(:product_model_rule, product_model_ids: [order.order_items.first.itemable.product.id])],
                                       apply_count_limit: -1)
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 99.9 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(199.8) # 99.9 * 4 - 99.9 * 2
      end
    end

    context 'and order does not contain all product model' do
      before do
        model1 = create(:product_model, price_table: { 'USD' => 100 })
        model2 = create(:product_model, price_table: { 'USD' => 200 })
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_model_rule, product_model_ids: [model1.id, model2.id])],
                                       apply_count_limit: 1)
        work1 = create(:work, model: model1)
        order.order_items.clear
        order.order_items << create(:order_item, itemable: work1, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(100 * 2)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount.round(2)).to eq(5)
        expect(calculator.price.round(2)).to eq(100 * 2 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(195) # 100 * 2 - 5
      end
    end
  end

  context 'when gives an order with percentage coupon that only for some product models' do
    context 'and apply count limit is 1' do
      before do
        order.coupon = create(:percentage_coupon, condition: 'simple',
                                                  coupon_rules: [create(:product_model_rule, product_model_ids: [order.order_items.first.itemable.product.id])],
                                                  apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount.round(2)).to eq((99.9 * 0.2).round(2))
        expect(calculator.price.round(2)).to eq((99.9 * 4 - 99.9 * 0.2).round(2))
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(379.62) # (99.9 * 4 - 99.9 * 0.2).round(2)
      end
    end

    context 'and apply count limit is no limit' do
      before do
        order.coupon = create(:percentage_coupon, condition: 'simple',
                                                  coupon_rules: [create(:product_model_rule, product_model_ids: [order.order_items.first.itemable.product.id])],
                                                  apply_count_limit: -1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount.round(2)).to eq((99.9 * 2 * 0.2).round(2))
        expect(calculator.price.round(2)).to eq((99.9 * 4 - 99.9 * 2 * 0.2).round(2))
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(359.64) # (99.9 * 4 - 99.9 * 2 * 0.2).round(2)
      end
    end

    context 'and order is not contains all product model' do
      before do
        model1 = create(:product_model, price_table: { 'USD' => 100 })
        model2 = create(:product_model, price_table: { 'USD' => 200 })
        order.coupon = create(:percentage_coupon, condition: 'simple',
                                                  coupon_rules: [create(:product_model_rule, product_model_ids: [model1.id, model2.id])],
                                                  apply_count_limit: 1)
        work1 = create(:work, model: model1)
        work2 = create(:work, model: model1)
        order.order_items.clear
        order.order_items << create(:order_item, itemable: work1, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(100 * 2)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount.round(2)).to eq((100 * 0.2).round(2))
        expect(calculator.price.round(2)).to eq((100 * 2 - 100 * 0.2).round(2))
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(180) # (100 * 2 - 100 * 0.2).round(2)
      end
    end
  end

  context 'when gives an order with fixed coupon that only for some designers' do
    context 'and apply count limit is 1' do
      before do
        designer = create(:designer)
        work = create(:work, user: designer)
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:designer_rule, designer_ids: [designer.id])],
                                       apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order_item = create(:order_item, quantity: 2, itemable: work)
        order.order_items << order_item
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5)
        expect(calculator.price).to eq(99.9 * 4 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(394.6) # 99.9 * 4 - 5
      end
    end

    context 'and apply count limit is no limit' do
      before do
        designer = create(:designer)
        work = create(:work, user: designer)
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:designer_rule, designer_ids: [designer.id])],
                                       apply_count_limit: -1)
        order.order_items.first.update(quantity: 2)
        order_item = create(:order_item, quantity: 2, itemable: work)
        order.order_items << order_item
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 5 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(389.6) # 99.9 * 4 - 5 * 2
      end

      it 'all item can discount and coupon prince > item.price' do
        designer = create(:designer)
        work = create(:work, user: designer)
        order.order_items.each do |item|
          item.update(itemable: work)
        end
        order.coupon = create(:coupon, price_table: { 'USD' => 999 },
                                       condition: 'simple',
                                       coupon_rules: [create(:designer_rule, designer_ids: [designer.id])],
                                       apply_count_limit: -1)
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9 * 4)
        expect(calculator.price).to eq(99.9 * 4 - 99.9 * 4)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(0) # 99.9 * 4 - 99.9 * 2
      end
    end
  end

  context 'when gives an order with fixed coupon that only for some designers and models' do
    context 'and apply count limit is 1' do
      before do
        designer = create(:designer)
        work = create(:work, user: designer)
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:designer_model_rule, designer_ids: [designer.id], product_model_ids: [work.product.id])],
                                       apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order_item = create(:order_item, quantity: 2, itemable: work)
        order.order_items << order_item
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5)
        expect(calculator.price).to eq(99.9 * 4 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(394.6) # 99.9 * 4 - 5
      end
    end

    context 'rails error when model_ids is not designer work model' do
      before do
        designer = create(:designer)
        work = create(:work, user: designer)
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:designer_model_rule, designer_ids: [designer.id], product_model_ids: ['invalid'])],
                                       apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order_item = create(:order_item, quantity: 2, itemable: work)
        order.order_items << order_item
      end

      it 'raises error' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect { calculator.discount }.to raise_error(CannotUseCouponError)
        expect { calculator.price }.to raise_error(CannotUseCouponError)
        expect(calculator.refund).to eq(0)
        expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
      end
    end

    context 'and apply count limit is no limit' do
      before do
        designer = create(:designer)
        work = create(:work, user: designer)
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:designer_model_rule, designer_ids: [designer.id], product_model_ids: [work.product.id])],
                                       apply_count_limit: -1)
        order.order_items.first.update(quantity: 2)
        order_item = create(:order_item, quantity: 2, itemable: work)
        order.order_items << order_item
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 5 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(389.6) # 99.9 * 4 - 5 * 2
      end
    end
  end

  context 'when gives an order with fixed coupon that only for some works' do
    context 'and apply count limit is 1' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:work_rule, work_gids: [order.order_items.first.itemable.to_gid_param])],
                                       apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5)
        expect(calculator.price).to eq(99.9 * 4 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(394.6) # 99.9 * 4 - 5
      end
    end

    context 'and apply count limit is 1 and discount > item.price' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:work_rule, work_gids: [order.order_items.first.itemable.to_gid_param])],
                                       apply_count_limit: 1,
                                       price_table: { 'USD' => 200 })
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9)
        expect(calculator.price).to eq(299.7) # 99.9 * 4 - 99.9
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(299.7) # 99.9 * 4 - 99.9
      end
    end

    context 'and apply count limit is no limit' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:work_rule, work_gids: [order.order_items.first.itemable.to_gid_param])],
                                       apply_count_limit: -1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 5 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(389.6) # 99.9 * 4 - 5 * 2
      end

      it 'limits to not discount more than model price' do
        order.coupon = create(:coupon, price_table: { 'USD' => 999 },
                                       condition: 'simple',
                                       coupon_rules: [create(:work_rule, work_gids: [order.order_items.first.itemable.to_gid_param])],
                                       apply_count_limit: -1)
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 99.9 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(199.8) # 99.9 * 4 - 99.9 * 2
      end

      it 'all item can discount and coupon prince > item.price' do
        work_gids = [order.order_items.first.itemable.to_gid_param,
                     order.order_items.last.itemable.to_gid_param]
        order.coupon = create(:coupon, price_table: { 'USD' => 999 },
                                       condition: 'simple',
                                       coupon_rules: [create(:work_rule, work_gids: work_gids)],
                                       apply_count_limit: -1)
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9 * 4)
        expect(calculator.price).to eq(99.9 * 4 - 99.9 * 4)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(0) # 99.9 * 4 - 99.9 * 2
      end
    end
  end

  context 'when gives an order with fixed coupon that only for some product category' do
    context 'and apply count limit is 1' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_category_rule, product_category_ids: [order.order_items.first.itemable.category.id])],
                                       apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5)
        expect(calculator.price).to eq(99.9 * 4 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(394.6) # 99.9 * 4 - 5
      end
    end

    context 'and apply count limit is 1 and with all product_categories' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_category_rule, product_category_ids: [-1])],
                                       apply_count_limit: 1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5)
        expect(calculator.price).to eq(99.9 * 4 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(394.6) # 99.9 * 4 - 5
      end
    end

    context 'and apply count limit is 1 and discount > item.price' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_category_rule, product_category_ids: [order.order_items.first.itemable.category.id])],
                                       apply_count_limit: 1,
                                       price_table: { 'USD' => 200 })
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9)
        expect(calculator.price).to eq(299.7) # 99.9 * 4 - 99.9
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(299.7) # 99.9 * 4 - 99.9
      end
    end

    context 'and apply count limit is no limit' do
      before do
        order.coupon = create(:coupon, condition: 'simple',
                                       coupon_rules: [create(:product_category_rule, product_category_ids: [order.order_items.first.itemable.category.id])],
                                       apply_count_limit: -1)
        order.order_items.first.update(quantity: 2)
        order.order_items << create(:order_item, quantity: 2)
      end

      it 'calculates correct amount' do
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(5 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 5 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(389.6) # 99.9 * 4 - 5 * 2
      end

      it 'limits to not discount more than model price' do
        order.coupon = create(:coupon, price_table: { 'USD' => 999 },
                                       condition: 'simple',
                                       coupon_rules: [create(:product_category_rule, product_category_ids: [order.order_items.first.itemable.category.id])],
                                       apply_count_limit: -1)
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9 * 2)
        expect(calculator.price).to eq(99.9 * 4 - 99.9 * 2)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(199.8) # 99.9 * 4 - 99.9 * 2
      end

      it 'all item can discount and coupon prince > item.price' do
        product_category_ids = [order.order_items.first.itemable.category.id,
                                order.order_items.last.itemable.category.id]
        order.coupon = create(:coupon, price_table: { 'USD' => 999 },
                                       condition: 'simple',
                                       coupon_rules: [create(:product_category_rule, product_category_ids: product_category_ids)],
                                       apply_count_limit: -1)
        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(99.9 * 4)
        expect(calculator.price).to eq(99.9 * 4 - 99.9 * 4)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(0) # 99.9 * 4 - 99.9 * 2
      end
    end
  end

  context 'when gives an order with super coupon' do
    before do
      order.coupon = create(:coupon, price_table: { 'USD' => 1000, 'TWD' => 30_000 })
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(99.9)
      expect(calculator.price).to eq(0)
      expect(calculator.refund).to eq(0)
    end
  end

  context 'when gives an order with shipping fee' do
    before do
      create(:fee, name: 'express', price_table: { 'USD' => 10, 'TWD' => 300 })
      order.shipping_info.update(shipping_way: 'express')
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(10)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(109.9)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(109.9)
    end
  end

  context 'when gives an order with refund' do
    before do
      CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
      CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
      order.refunds.create(amount: 99.9)
      order.refunds.reload
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(99.9)
      expect(calculator.refund).to eq(99.9)
      expect(calculator.price_after_refund).to eq(0) # 99.9 - 99.9
    end
  end

  context 'when gives an order with part refund' do
    before do
      CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
      CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
      order.refunds.create(amount: 50)
      order.refunds.reload
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(0)
      expect(calculator.price).to eq(99.9)
      expect(calculator.refund).to eq(50.0)
      expect(calculator.price_after_refund).to eq(49.9) # 99.9 - 50.0
    end
  end

  context 'for a complex order' do
    before do
      order.order_items.first.update(quantity: 3)
      order.coupon = create(:coupon)
      create(:fee, name: 'express', price_table: { 'USD' => 10, 'TWD' => 300 })
      order.shipping_info.update(shipping_way: 'express')
      order.refunds.create(amount: 50)
      order.refunds.reload
      order.save
      CurrencyType.find_by(code: 'USD').update(rate: 30)
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(299.7)
      expect(calculator.shipping).to eq(10)
      expect(calculator.discount).to eq(5)
      expect(calculator.price).to eq(304.7) # 99.9 * 3 + 10 - 5
      expect(calculator.refund).to eq(50.0)
      expect(calculator.price_after_refund).to eq(254.7) # 99.9 * 3 + 10 - 5 - 50
    end

    it 'calculates correct amount in TWD' do
      calculator = PriceCalculator.new(order)
      expect(calculator.subtotal('TWD')).to eq(8991.0)
      expect(calculator.shipping('TWD')).to eq(10 * 30)
      expect(calculator.discount('TWD')).to eq(5 * 30)
      expect(calculator.price('TWD')).to eq(9141) # (99.9 * 3 + 10 - 5) * 30
      expect(calculator.refund('TWD')).to eq(50.0 * 30)
      expect(calculator.price_after_refund('TWD')).to eq(7641.0) # (99.9 * 3 + 10 - 5) * 30 - (50.0 * 30)
    end

    it 'price calculator currency not eq order currency' do
      calculator = PriceCalculator.new(order, 'TWD')
      expect(calculator.subtotal).to eq(8997.0)
      expect(calculator.shipping).to eq(10 * 30)
      expect(calculator.discount).to eq(5 * 30)
      expect(calculator.price).to eq(9147.0) # 8997.0 + (10*30) - (5*30)
      expect(calculator.refund).to eq(50.0 * 30)
      expect(calculator.price_after_refund).to eq(7647.0) # 9147.0 - 1500.0
    end
  end

  describe '#actual_discount and #actual_price' do
    before do
      order.coupon = create(:percentage_coupon)
      # 9.27 * 20% = 1.854 => 1.86
      itemable = create(:work, price_table: { 'USD' => 9.27 })
      order.order_items = [create(:order_item, itemable: itemable)]
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(9.27)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(1.854)
      expect(calculator.actual_discount).to eq(1.86)
      expect(calculator.price).to eq(BigDecimal.new('9.27') - 1.86)
      expect(calculator.actual_price).to eq(BigDecimal.new('9.27') - 1.86)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(BigDecimal.new('9.27') - 1.86)
    end
  end

  describe '#for base_price_type' do
    let(:product) do
      create(:product_model, price_table: { 'USD' => 9.27 })
    end

    before do
      itemable1 = create(:work, product: product, price_table: { 'USD' => 6.27 })
      itemable2 = create(:work, price_table: { 'USD' => 5.27 })
      order_item1 = create(:order_item, itemable: itemable1, prices: { 'USD' => 6.27 }, quantity: 5)
      order_item2 = create(:order_item, itemable: itemable2, prices: { 'USD' => 5.27 }, quantity: 3)
      order.order_items = [order_item1, order_item2]
    end

    it 'base_price_type is original' do
      # subtotal = 9.27 + 6.27 * 4 + 5.27 * 3
      # discount = 9.27 * 0.2
      order.coupon = create(:percentage_coupon, condition: 'simple',
                                                coupon_rules: [create(:product_model_rule, product_model_ids: [product.id])],
                                                base_price_type: 'original',
                                                apply_count_limit: 1)
      calculator = PriceCalculator.new(order, 'USD')
      expect(calculator.subtotal).to eq(50.16)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(1.854)
      expect(calculator.actual_discount).to eq(1.86)
      expect(calculator.price).to eq(BigDecimal.new('50.16') - 1.86)
      expect(calculator.actual_price).to eq(BigDecimal.new('50.16') - 1.86)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(BigDecimal.new('50.16') - 1.86)
    end

    it 'base_price_type is special' do
      # subtotal = 6.27 * 5 + 5.27 * 3
      # discount = 6.27 * 0.2
      order.coupon = create(:percentage_coupon, condition: 'simple',
                                                coupon_rules: [create(:product_model_rule, product_model_ids: [product.id])],
                                                base_price_type: 'special',
                                                apply_count_limit: 1)
      calculator = PriceCalculator.new(order, 'USD')
      expect(calculator.subtotal).to eq(47.16)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(1.254)
      expect(calculator.actual_discount).to eq(1.26)
      expect(calculator.price).to eq(BigDecimal.new('47.16') - 1.26)
      expect(calculator.actual_price).to eq(BigDecimal.new('47.16') - 1.26)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(BigDecimal.new('47.16') - 1.26)
    end
  end

  describe 'coupon has two rules' do
    let(:product1) { create(:product_model, price_table: { 'USD' => 9.27 }) }
    let(:product2) { create(:product_model, price_table: { 'USD' => 9.27 }) }
    let(:designer1) { create(:designer) }
    let(:designer2) { create(:designer) }
    before do
      itemable1 = create(:work, user: designer1, product: product1, price_table: { 'USD' => 6.27 })
      itemable2 = create(:work, user: designer2, product: product2, price_table: { 'USD' => 5.27 })
      order_item1 = create(:order_item, itemable: itemable1, prices: { 'USD' => 6.27 }, quantity: 5)
      order_item2 = create(:order_item, itemable: itemable2, prices: { 'USD' => 5.27 }, quantity: 3)
      order.order_items = [order_item1, order_item2]
    end

    it 'coupon_rules condition is designer A and designer B' do
      order.coupon = create(:coupon, condition: 'rules',
                                     coupon_rules: [create(:designer_rule, designer_ids: [designer1.id], quantity: 2),
                                                    create(:designer_rule, designer_ids: [designer2.id], quantity: 1)],
                                     apply_count_limit: 3)

      calculator = PriceCalculator.new(order, 'USD')
      expect(calculator.subtotal).to eq(47.16)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(10)
      expect(calculator.actual_discount).to eq(10)
      expect(calculator.price).to eq(BigDecimal.new('47.16') - 10)
      expect(calculator.actual_price).to eq(BigDecimal.new('47.16') - 10)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(BigDecimal.new('47.16') - 10)
    end

    it 'coupon_rules condition is model A and model B' do
      order.coupon = create(:coupon, condition: 'rules',
                            coupon_rules: [create(:product_model_rule, product_model_ids: [product1.id], quantity: 1),
                                           create(:product_model_rule, product_model_ids: [product2.id], quantity: 1)],
                            apply_count_limit: 2)

      calculator = PriceCalculator.new(order, 'USD')
      expect(calculator.subtotal).to eq(47.16)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(10)
      expect(calculator.actual_discount).to eq(10)
      expect(calculator.price).to eq(BigDecimal.new('47.16') - 10)
      expect(calculator.actual_price).to eq(BigDecimal.new('47.16') - 10)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(BigDecimal.new('47.16') - 10)
    end

    it 'coupon_rules is same' do
      order.coupon = create(:coupon, condition: 'rules',
                            coupon_rules: [create(:product_model_rule, product_model_ids: [product1.id], quantity: 1),
                                           create(:product_model_rule, product_model_ids: [product1.id], quantity: 1)],
                            apply_count_limit: 2)

      calculator = PriceCalculator.new(order, 'USD')
      expect(calculator.subtotal).to eq(47.16)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(10)
      expect(calculator.actual_discount).to eq(10)
      expect(calculator.price).to eq(BigDecimal.new('47.16') - 10)
      expect(calculator.actual_price).to eq(BigDecimal.new('47.16') - 10)
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq(BigDecimal.new('47.16') - 10)
    end
  end

  context '#order_adjustments_value' do
    it 'definitely seperates different target type adjustments_value from the other' do
      order.order_adjustments.create value: -30, order: order, source: promotion, event: 'apply'
      order.order_adjustments.create value: -40, order: order, source_type: 'Fee', source_id: 2, event: 'apply'
      order.order_adjustments.create value: -50, order: order, source_type: 'Fee', source_id: 3, event: 'apply'
      order.order_adjustments.create value: -60, order: order, source_type: 'Fee', source_id: 4, event: 'apply'
      price_calculator = PriceCalculator.new(order)
      expect(price_calculator.order_adjustments_value).to eq(-180)
    end
  end

  describe '#shipping_fee_discount' do
    Given!(:promotion) { create :promotion_for_shipping_fee }

    context 'when order has shipping_fee' do
      Given(:order) { create :shipping_to_tw_order }
      Given(:calculator) { PriceCalculator.new(order) }
      Given {
        create :site_setting, key: 'ShippingFeeSwitch', value: 'true'
        order.stub(:available_shipping_fee_promotions).and_return([promotion])
        order.shipping_fee = calculator.shipping
        order.apply_with_avaliable_shipping_fee_promotion
      }
      Then { expect(calculator.shipping_fee_discount).to eq calculator.shipping }
      And { expect(calculator.shipping_fee_discount).to eq 65 }
    end
  end
end
