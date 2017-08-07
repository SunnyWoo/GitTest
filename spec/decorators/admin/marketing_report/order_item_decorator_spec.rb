require 'spec_helper'

describe Admin::MarketingReport::OrderItemDecorator do
  Given(:order_item) { create :order_item, :with_delivering, quantity: 3, discount: 100 }
  Given(:decorated_item) { Admin::MarketingReport::OrderItemDecorator.decorate order_item }
  Then { decorated_item.itemable_user_display_name == order_item.itemable.user.display_name }
  And { decorated_item.order_embedded_coupon_code == order_item.order.embedded_coupon.try(:code) }

  context 'for pricing' do
    When do
      allow(decorated_item).to receive(:price).and_return(99.0)
      allow(decorated_item).to receive(:original_price).and_return(109.0)
    end
    Then { decorated_item.special_price_profit == 10 }
    And { decorated_item.actual_total_amount == (99.0 * 3 - 100) }
  end
end
