require 'spec_helper'

describe Pricing::OrderPriceCalculator do
  subject(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
  Given(:target_currency) { order.currency }
  Given(:order) { create(:order).reload }
  Given(:first_item) { order.order_items.first }
  Given(:promotion) { create :standardized_work_promotion }
  Given(:order_promotion) { create :promotion_for_order_price }
  Given(:builder) do
    Class.new do
      include ActsAsAdjustmentBuilder
    end.new
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
        # TODO: https://github.com/commandp/commandp-service/blob/3da8933fb10998f7b620d01a694a3208aa0205c1/app/models/pricing/order_price_calculator.rb#L198
        # 上面分支合并后 改用 builder.build_adjustment
        # builder.build_adjustment(order, first_item, promotion, :apply, -30, 2)
        order.order_items.first.adjustments.create order_id: order.id, source: promotion, event: 'apply', value: -30, quantity: 2
        expect(calculator.subtotal).to eq(299.7 - 30)
        order.adjustments.delete_all
      end
    end

    context 'calculates correct amount with order item adjustments values' do
      it 'calculates only for adjustment target type for special' do
        builder.build_adjustment(order, order, order_promotion, :apply, -100)
        expect(calculator.subtotal).to eq(299.7)
        expect(calculator.discount).to eq(100)
        expect(calculator.price).to eq(299.7 - 100)
      end
    end

    it 'calculates correct amount with both order_item as well as order adjustment' do
      builder.build_adjustment(order, order, order_promotion, :apply, -100)
      allow(calculator).to receive(:purge_promotion_order_adjustments_if_necessary)
      expect(calculator.subtotal).to eq(299.7)
      expect(calculator.discount).to eq(100)
      expect(calculator.price).to eq(199.7)
    end

    it 'when discount exceed subtotal' do
      builder.build_adjustment(order, order, order_promotion, :apply, -600)
      allow(calculator).to receive(:purge_promotion_order_adjustments_if_necessary)
      expect(calculator.subtotal).to eq(299.7)
      expect(calculator.discount).to eq(299.7)
      expect(calculator.shipping).to eq(0)
      expect(calculator.price).to eq(0)
    end

    it 'returns 0 with both order and item adjustments_value exceeding the sum of order items price' do
      order.order_items.first.adjustments.create order_id: order.id, source: promotion, event: 'apply', value: -50_000
      builder.build_adjustment(order, order, order_promotion, :apply, -50_000)
      expect(calculator.subtotal).to eq(0.0)
      expect(calculator.discount).to eq(0.0)
      expect(calculator.price).to eq(0.0)
      order.adjustments.delete_all
    end

    it 'when discount all' do
      order.order_items.first.adjustments.create order_id: order.id, source: promotion, event: 'apply', value: -30
      builder.build_adjustment(order, order, order_promotion, :apply, -50_000)
      expect(calculator.subtotal).to eq(299.7 - 30)
      expect(calculator.discount).to eq(299.7 - 30)
      expect(calculator.price).to eq(0.0)
      order.adjustments.delete_all
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

    it 'calculates correct amount with order level adjustment' do
      builder.build_adjustment(order, order, order_promotion, :apply, -20)
      allow(calculator).to receive(:purge_promotion_order_adjustments_if_necessary)
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
      order.adjustments.delete_all
    end

    it 'calculates correct amount with order level adjustment' do
      allow(calculator).to receive(:purge_promotion_order_adjustments_if_necessary)
      builder.build_adjustment(order, order, order_promotion, :apply, -20)
      expect(calculator.subtotal).to eq(99.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount.round(2)).to eq((99.9 * 0.2 + 20).round(2))
      expect(calculator.price.round(2)).to eq((99.9 * 0.8 - 20).round(2))
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq((99.9 * 0.8 - 20).round(2))
    end

    it 'calculates correct amount with order level adjustment' do
      order.order_items.first.adjustments.create source: promotion, event: 'apply', value: -20, quantity: 1
      builder.build_adjustment(order, order, order_promotion, :apply, -20)
      expect(calculator.subtotal).to eq(79.9)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount.round(2)).to eq((79.9 * 0.2 + 20).round(2))
      expect(calculator.price.round(2)).to eq((79.9 * 0.8 - 20).round(2))
      expect(calculator.refund).to eq(0)
      expect(calculator.price_after_refund).to eq((79.9 * 0.8 - 20).round(2))
      order.adjustments.delete_all
    end
  end

  context 'when gives an order with fixed coupon that threshold >= 100' do
    before do
      order.coupon = create(:coupon, condition: 'simple',
                                     coupon_rules: [create(:threshold_rule, threshold_price_table: { 'USD' => 100 } )])
    end

    # it 'raises error' do
    #   expect(calculator.subtotal).to eq(99.9)
    #   expect(calculator.shipping).to eq(0)
    #   expect { calculator.discount }.to raise_error(CannotUseCouponError)
    #   expect { calculator.price }.to raise_error(CannotUseCouponError)
    #   expect(calculator.refund).to eq(0)
    #   expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
    # end

    # it 'raises error with special priced work' do
    #   itemable = create(:work, price_table: { 'USD' => 9 })
    #   order.order_items = [create(:order_item, itemable: itemable)]
    #   expect(calculator.subtotal).to eq(9)
    #   expect(calculator.shipping).to eq(0)
    #   expect { calculator.discount }.to raise_error(CannotUseCouponError)
    #   expect { calculator.price }.to raise_error(CannotUseCouponError)
    #   expect(calculator.refund).to eq(0)
    #   expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
    # end
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

    # it 'calculates correct amount with adjustments' do
    #   order.order_items.first.adjustments.create source: promotion, target: 'special', event: 'apply', value: -20
    #   expect(calculator.subtotal).to eq(79.9)
    #   expect(calculator.shipping).to eq(0)
    #   expect(calculator.discount).to eq(5)
    #   expect(calculator.price).to eq(74.9)
    #   expect(calculator.refund).to eq(0)
    #   expect(calculator.price_after_refund).to eq(74.9)
    # end

    # it 'raise error amount with adjustments value made subtotal lower than threshold' do
    #   order.order_items.first.adjustments.create source: promotion, target: 'special', event: 'apply', value: -60
    #   expect(calculator.subtotal).to eq(39.9)
    #   expect(calculator.shipping).to eq(0)
    #   expect { calculator.discount }.to raise_error(CannotUseCouponError)
    #   expect { calculator.price }.to raise_error(CannotUseCouponError)
    #   expect(calculator.refund).to eq(0)
    #   expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
    # end
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

      # it 'calculates correct amount with item level adjustments' do
      #   order.order_items.first.adjustments.build source: promotion, target: 'special', event: 'apply', value: -40, quantity: 2
      #   expect(calculator.subtotal).to eq(99.9 * 2 + 79.9 * 2)
      #   expect(calculator.shipping).to eq(0)
      #   expect(calculator.discount).to eq(5)
      #   expect(calculator.price).to eq(99.9 * 2 + 79.9 * 2 - 5)
      #   expect(calculator.refund).to eq(0)
      #   expect(calculator.price_after_refund).to eq(99.9 * 2 + 79.9 * 2 - 5)
      # end

      it 'calculates correct amount with order adjustments' do
        builder.build_adjustment(order, order, order_promotion, :apply, -20)
        allow(calculator).to receive(:purge_promotion_order_adjustments_if_necessary)

        expect(calculator.subtotal).to eq(99.9 * 4)
        expect(calculator.shipping).to eq(0)
        expect(calculator.discount).to eq(20 + 5) # order_level + coupon
        expect(calculator.price).to eq(99.9 * 4 - 20 - 5)
        expect(calculator.refund).to eq(0)
        expect(calculator.price_after_refund).to eq(99.9 * 4 - 20 - 5)
      end

      # it 'calculates correct amount with both item and order adjustments' do
      #   item = order.order_items.first
      #   item.adjustments.build source: promotion, event: 'apply', value: -40, quantity: 2 # -20 each item
      #   order.order_adjustments.build source: promotion, adjustable: order, event: 'apply', value: -20, quantity: 1

      #   expect(calculator.subtotal).to eq(99.9 * 2 + 79.9 * 2)
      #   expect(calculator.shipping).to eq(0)
      #   expect(calculator.discount).to eq(20 + 5) # order level + coupon
      #   expect(calculator.price).to eq(99.9 * 2 + 79.9 * 2 - 25)
      #   expect(calculator.refund).to eq(0)
      #   expect(calculator.price_after_refund).to eq(99.9 * 2 + 79.9 * 2 - 20 - 5)
      # end
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

  # context 'when gives an order with fixed coupon that only for shipping fee' do
  #   before do
  #     create(:fee, name: 'express', price_table: { 'USD' => 150 })
  #     order.shipping_info.shipping_way = 'express'
  #     order.coupon = create(:coupon, condition: 'shipping_fee')
  #   end

  #   it 'calculates correct amount' do
  #     expect(calculator.subtotal).to eq(99.9)
  #     expect(calculator.shipping).to eq(150)
  #     expect(calculator.discount).to eq(5)
  #     expect(calculator.price).to eq(99.9 + 150 - 5)
  #     expect(calculator.refund).to eq(0)
  #     expect(calculator.price_after_refund).to eq(244.9) # 99.9 + 150 - 5
  #   end
  # end

  # context 'when gives an order with fixed super coupon that only for shipping fee' do
  #   before do
  #     create(:fee, name: 'express', price_table: { 'USD' => 150 })
  #     order.shipping_info.shipping_way = 'express'
  #     order.coupon = create(:coupon, condition: 'shipping_fee', price_table: { 'USD' => 1000 })
  #   end

  #   it 'calculates correct amount' do
  #     expect(calculator.subtotal).to eq(99.9)
  #     expect(calculator.shipping).to eq(150)
  #     expect(calculator.discount).to eq(150)
  #     expect(calculator.price).to eq(99.9 + 150 - 150)
  #     expect(calculator.refund).to eq(0)
  #     expect(calculator.price_after_refund).to eq(99.9) # 99.9 + 150 - 150
  #   end
  # end

  # context 'when gives an order with percentage coupon that only for shipping fee' do
  #   before do
  #     create(:fee, name: 'express', price_table: { 'USD' => 150 })
  #     order.shipping_info.shipping_way = 'express'
  #     order.coupon = create(:percentage_coupon, condition: 'shipping_fee')
  #   end

  #   it 'calculates correct amount' do
  #     expect(calculator.subtotal).to eq(99.9)
  #     expect(calculator.shipping).to eq(150)
  #     expect(calculator.discount).to eq(150 * 0.2)
  #     expect(calculator.price).to eq(99.9 + 150 - 150 * 0.2)
  #     expect(calculator.refund).to eq(0)
  #     expect(calculator.price_after_refund).to eq(219.9) # 99.9 + 150 - 150 * 0.2
  #   end
  # end

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

    # context 'rails error when model_ids is not designer work model' do
    #   before do
    #     designer = create(:designer)
    #     work = create(:work, user: designer)
    #     order.coupon = create(:coupon, condition: 'simple',
    #                                    coupon_rules: [create(:designer_model_rule, designer_ids: [designer.id], product_model_ids: ['invalid'])],
    #                                    apply_count_limit: 1)
    #     order.order_items.first.update(quantity: 2)
    #     order_item = create(:order_item, quantity: 2, itemable: work)
    #     order.order_items << order_item
    #   end

    #   it 'raises error' do
    #     expect(calculator.subtotal).to eq(99.9 * 4)
    #     expect(calculator.shipping).to eq(0)
    #     expect { calculator.discount }.to raise_error(CannotUseCouponError)
    #     expect { calculator.price }.to raise_error(CannotUseCouponError)
    #     expect(calculator.refund).to eq(0)
    #     expect { calculator.price_after_refund }.to raise_error(CannotUseCouponError)
    #   end
    # end

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

  context 'when gives an order with coupon for bdevent' do
    before do
      bdevent = create(:bdevent)
      bdevent.works << order.order_items.first.itemable
      order.order_items.first.update(quantity: 3)
      order.coupon = create(:coupon, condition: 'simple',
                                     coupon_rules: [create(:bdevent_rule, bdevent_id: bdevent.id)],
                                     apply_count_limit: 1)
      order.save
    end

    it 'calculates correct amount' do
      expect(calculator.subtotal).to eq(299.7)
      expect(calculator.shipping).to eq(0)
      expect(calculator.discount).to eq(99.9)
      expect(calculator.price).to eq(199.8)
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

    context 'with TWD as argument when called' do
      it 'calculates correct amount' do
        expect(calculator.subtotal('TWD')).to eq(8991.0)
        expect(calculator.shipping('TWD')).to eq(10 * 30)
        expect(calculator.discount('TWD')).to eq(5 * 30)
        expect(calculator.price('TWD')).to eq(9141) # (99.9 * 3 + 10 - 5) * 30
        expect(calculator.refund('TWD')).to eq(50.0 * 30)
        expect(calculator.price_after_refund('TWD')).to eq(7641.0) # (99.9 * 3 + 10 - 5) * 30 - (50.0 * 30)
      end
    end

    context 'with TWD configured by initializer' do
      Given(:target_currency) { 'TWD' }
      it 'price calculator currency not eq order currency' do
        expect(calculator.subtotal).to eq(8997.0)
        expect(calculator.shipping).to eq(10 * 30)
        expect(calculator.discount).to eq(5 * 30)
        expect(calculator.price).to eq(9147.0) # 8997.0 + (10*30) - (5*30)
        expect(calculator.refund).to eq(50.0 * 30)
        expect(calculator.price_after_refund).to eq(7647.0) # 9147.0 - 1500.0
      end
    end
  end

  describe '#actual_discount and #actual_price' do
    before do
      order.calculate_price!
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

    # it 'base_price_type is original' do
    #   # subtotal = 9.27 + 6.27 * 4 + 5.27 * 3
    #   # discount = 9.27 * 0.2
    #   order.coupon = create(:percentage_coupon, condition: 'simple',
    #                                             coupon_rules: [create(:product_model_rule, product_model_ids: [product.id])],
    #                                             base_price_type: 'original',
    #                                             apply_count_limit: 1)
    #   # calculator = PriceCalculator.new(order, 'USD')
    #   expect(calculator.subtotal).to eq(50.16)
    #   expect(calculator.shipping).to eq(0)
    #   expect(calculator.discount).to eq(1.854)
    #   expect(calculator.actual_discount).to eq(1.86)
    #   expect(calculator.price).to eq(BigDecimal.new('50.16') - 1.86)
    #   expect(calculator.actual_price).to eq(BigDecimal.new('50.16') - 1.86)
    #   expect(calculator.refund).to eq(0)
    #   expect(calculator.price_after_refund).to eq(BigDecimal.new('50.16') - 1.86)
    # end

    it 'base_price_type is special' do
      # subtotal = 6.27 * 5 + 5.27 * 3
      # discount = 6.27 * 0.2
      order.coupon = create(:percentage_coupon, condition: 'simple',
                                                coupon_rules: [create(:product_model_rule, product_model_ids: [product.id])],
                                                base_price_type: 'special',
                                                apply_count_limit: 1)
      # calculator = PriceCalculator.new(order, 'USD')
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

      # calculator = PriceCalculator.new(order, 'USD')
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
      order.coupon = create(
        :coupon, condition: 'rules',
                 coupon_rules: [
                   create(:product_model_rule, product_model_ids: [product1.id], quantity: 1),
                   create(:product_model_rule, product_model_ids: [product2.id], quantity: 1)
                 ],
                 apply_count_limit: 2
      )

      # calculator = PriceCalculator.new(order, 'USD')
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

      # calculator = PriceCalculator.new(order, 'USD')
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

  # context '#order_adjustments_value' do
  #   it 'definitely seperates different target type adjustments_value from the other' do
  #     order.order_adjustments.create value: -30, order: order, source: promotion, event: 'apply'
  #     order.order_adjustments.create value: -40, order: order, source_type: 'Fee', source_id: 2, event: 'apply'
  #     order.order_adjustments.create value: -50, order: order, source_type: 'Fee', source_id: 3, event: 'apply'
  #     order.order_adjustments.create value: -60, order: order, source_type: 'Fee', source_id: 4, event: 'apply'
  #     expect(order.price_calculator.order_adjustments_value).to eq(-180)
  #   end
  # end

  describe '#shipping_fee_discount' do
    Given!(:promotion) { create :promotion_for_shipping_fee, aasm_state: :started }

    context 'when order has shipping_fee' do
      Given(:order) { create :shipping_to_tw_order }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given {
        create :site_setting, key: 'ShippingFeeSwitch', value: 'true'
        allow(calculator).to receive(:available_shipping_fee_promotion).and_return(promotion)
        order.pricing = calculator.process!
        order.save
      }
      Then { calculator.subtotal == 99.9 }
      And { calculator.discount == 0 }
      And { calculator.shipping == 65 }
      And { calculator.shipping_fee_discount == 65 }
      And { calculator.price == 99.9 }

      And { order.subtotal = 99.9 }
      And { order.discount == 0 }
      And { order.shipping_fee == 65 }
      And { order.shipping_fee_discount == 65 }
      And { order.price == 99.9 }

      Given { order.pricing = calculator.process! }
      And { order.subtotal = 99.9 }
      And { order.discount == 0 }
      And { order.shipping_fee == 65 }
      And { order.shipping_fee_discount == 65 }
      And { order.price == 99.9 }
    end

    context 'when order with coupon and has shipping_fee' do
      Given(:order) { create :shipping_to_tw_order, :with_coupon }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given {
        create :site_setting, key: 'ShippingFeeSwitch', value: 'true'
        allow(calculator).to receive(:available_shipping_fee_promotion).and_return(promotion)
      }
      Then { calculator.subtotal == 99.9 }
      And { calculator.discount == 5 }
      And { calculator.shipping == 65 }
      And { calculator.shipping_fee_discount == 65 }
      And { calculator.price == 94.9 }
    end

    context 'when order with coupon that is not include promotion' do
      Given(:coupon) { create :coupon, is_not_include_promotion: true }
      Given(:order) { create :shipping_to_tw_order, coupon: coupon }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given { create :site_setting, key: 'ShippingFeeSwitch', value: 'true' }
      Then { calculator.subtotal == 99.9 }
      And { calculator.discount == 5 }
      And { calculator.shipping == 65 }
      And { calculator.shipping_fee_discount == 0 }
      And { calculator.price == 159.9 }
    end

    context 'when order is build in shopping cart with coupon that is not include promotion' do
      Given(:coupon) { create :coupon, is_not_include_promotion: true }
      Given(:order) { build :shipping_to_tw_order, coupon: coupon }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given { create :site_setting, key: 'ShippingFeeSwitch', value: 'true' }
      When { order.order_items << build(:order_item) }
      Then { calculator.subtotal == 99.9 }
      And { calculator.discount == 5 }
      And { calculator.shipping == 65 }
      And { calculator.shipping_fee_discount == 0 } # promotion would be ignored.
      And { calculator.price == 159.9 }
    end

    context 'when order with coupon and has shipping_fee and is not include promotion' do
      context 'with available promotion for standardized_work_promotion' do
        Given(:promotion) { create :promotion_for_order_price, aasm_state: :started }
        Given(:coupon) { create :coupon, is_not_include_promotion: true, is_free_shipping: true }
        Given(:order) { create :shipping_to_tw_order, coupon: coupon }
        Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
        Given { create :site_setting, key: 'ShippingFeeSwitch', value: 'true' }
        Then { calculator.subtotal == 99.9 }
        And { calculator.discount == 5 }
        And { calculator.shipping == 65 }
        And { calculator.shipping_fee_discount == 0 }
        And { calculator.price == 159.9 }
      end

      context 'with available promotion for free_shipping_coupon' do
        Given(:promotion) { create :promotion_for_free_shipping_coupon, aasm_state: :started }
        Given(:coupon) { create :coupon, is_not_include_promotion: true, is_free_shipping: true }
        Given(:order) { create :shipping_to_tw_order, coupon: coupon }
        Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
        Given { create :site_setting, key: 'ShippingFeeSwitch', value: 'true' }
        Then { calculator.subtotal == 99.9 }
        And { calculator.discount == 5 }
        And { calculator.shipping == 65 }
        And { calculator.shipping_fee_discount == 65 }
        And { calculator.price == 94.9 }
      end
    end
  end

  context 'calculation secondly on changed order' do
    context 'with coupon' do
      Given { order.coupon = create(:coupon) }
      When do
        order.calculate_price!
        order.reload
      end
      Then { expect(order.discount).to eq 5 }
      And { expect(order.adjustments.size).to eq 1 }
      context 'but removed it and cacluate again' do
        When do
          order.coupon = nil
          order.calculate_price!
        end
        Then { expect(order.discount).to eq 0 }
        And { expect(order.reload.adjustments.size).to eq 0 }
      end
    end
  end

  context '#process!' do
    context 'with Promotion::ForProductModel' do
      Given(:promotion_reference) { create :promotion_reference, :product_model }
      Given(:promotion) { promotion_reference.promotion }
      Given(:product) { promotion_reference.promotable }
      Given(:order) { create(:order) }
      Given(:work) { create :work, product: product }
      Given(:order_item) { create :order_item, itemable: work, order: order, quantity: 2 }
      before do
        promotion.update(aasm_state: :started, begins_at: Time.zone.yesterday, ends_at: Time.zone.today.next_day)
        order.reload.order_items.where.not(id: order_item.id).delete_all
      end

      Then { Pricing::OrderPriceCalculator.new(order).process!.subtotal == promotion.price_tier.prices[order.currency] * order_item.quantity }
    end

    context 'when order has shippign_fee' do
      Given(:order) { create :shipping_to_tw_order }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given { create :site_setting, key: 'ShippingFeeSwitch', value: 'true' }
      Given(:process_result) { calculator.process! }
      Then { process_result.subtotal == 99.9 }
      And { process_result.discount == 0 }
      And { process_result.shipping == 65 }
      And { process_result.shipping_fee_discount == 0 }
      And { process_result.price_without_shipping_fee == 99.9 }
      And { process_result.price == 164.9 }
    end

    context 'when order has shipping_fee and shipping_fee_discount' do
      Given(:promotion) { create :promotion_for_shipping_fee, aasm_state: :started }
      Given(:order) { create :shipping_to_tw_order }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given {
        create :site_setting, key: 'ShippingFeeSwitch', value: 'true'
        allow(calculator).to receive(:available_shipping_fee_promotion).and_return(promotion)
      }
      Given(:process_result) { calculator.process! }
      Then { process_result.subtotal == 99.9 }
      And { process_result.discount == 0 }
      And { process_result.shipping == 65 }
      And { process_result.shipping_fee_discount == 65 }
      And { process_result.price_without_shipping_fee == 99.9 }
      And { process_result.price == 99.9 }
    end

    context "when order source is shop can't use promotion for shipping fee" do
      Given(:promotion) { create :promotion_for_shipping_fee, aasm_state: :started }
      Given(:order) { create :shipping_to_tw_order, source: :shop }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given {
        create :site_setting, key: 'ShippingFeeSwitch', value: 'true'
        allow(calculator).to receive(:available_shipping_fee_promotion).and_return(promotion)
      }
      Given(:process_result) { calculator.process! }
      Then { process_result.subtotal == 99.9 }
      And { process_result.discount == 0 }
      And { process_result.shipping == 65 }
      And { process_result.shipping_fee_discount == 0 }
      And { process_result.price_without_shipping_fee == 99.9 }
      And { process_result.price == 99.9 + 65 }
    end

    context 'with discount' do
      Given(:promotion) { create :promotion_for_order_price, aasm_state: :started }
      Given(:coupon) { create :coupon, is_not_include_promotion: true, is_free_shipping: true }
      Given(:order) { create :shipping_to_tw_order, coupon: coupon }
      Given(:calculator) { Pricing::OrderPriceCalculator.new(order, target_currency) }
      Given { create :site_setting, key: 'ShippingFeeSwitch', value: 'true' }
      Given(:process_result) { calculator.process! }
      Then { process_result.subtotal == 99.9 }
      And { process_result.discount == 5 }
      And { process_result.shipping == 65 }
      And { process_result.shipping_fee_discount == 0 }
      And { process_result.price_without_shipping_fee == 94.9 }
      And { process_result.price == 159.9 }
    end
  end
end
