require 'spec_helper'

describe Api::V3::Payment::RedeemController, :api_v3, type: :controller do
  context '#begin', signed_in: :normal do
    Given(:work) { create(:work, :with_iphone6_model) }
    Given(:redeem_work) { create(:work, :redeem) }
    Given(:coupon) { create(:coupon) }
    Given(:redeem_coupon) do
      create(:coupon, condition: 'simple', coupon_rules: [create(:work_rule, work_gids: [redeem_work.to_gid_param])])
    end
    Given(:order_item) { create(:order_item, itemable: redeem_work) }

    context 'returns true' do
      Given(:order) do create :pending_order, user: user,
                                              payment_method: 'redeem',
                                              coupon: redeem_coupon,
                                              order_items: [order_item]
      end
      Given { order.order_items.where.not(id: order_item.id).delete_all }
      When { get :begin, order_no: order.order_no, access_token: access_token }
      Then { response.status == 200 }
      And { order.reload.paid? }
      And { response_json['status'] == true }
      And { response_json['order_no'] == order.order_no }
    end

    context 'returns false when order_items over then 1' do
      Given(:order) do
        create :pending_order, user: user, payment_method: 'redeem',
                               coupon: redeem_coupon, order_items: [order_item]
      end
      When { get :begin, order_no: order.order_no, access_token: access_token }
      Then { response.status == 400 }
      And { order.reload.paid? == false }
      And { response_json['status'] == false }
      And { response_json['error'] == '兌換商品數量大於一' }
    end

    context 'returns false when coupon is null' do
      Given(:order) do
        create :pending_order, user: user, payment_method: 'redeem',
                               coupon: nil, order_items: [order_item]
      end
      Given { order.order_items.where.not(id: order_item.id).delete_all }
      When { get :begin, order_no: order.order_no, access_token: access_token }
      Then { response.status == 400 }
      And { order.reload.paid? == false }
      And { response_json['status'] == false }
      And { response_json['error'] == '沒有兌換碼' }
    end
  end
end
