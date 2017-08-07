# == Schema Information
#
# Table name: order_items
#
#  id               :integer          not null, primary key
#  order_id         :integer
#  itemable_id      :integer
#  itemable_type    :string(255)
#  quantity         :integer
#  created_at       :datetime
#  updated_at       :datetime
#  timestamp_no     :integer
#  print_at         :datetime
#  aasm_state       :string(255)
#  pdf              :string(255)
#  prices           :json
#  original_prices  :json
#  discount         :decimal(8, 2)
#  remote_id        :integer
#  delivered        :boolean          default(FALSE)
#  deliver_complete :boolean          default(FALSE)
#  remote_info      :json
#  selling_prices   :json
#

require 'spec_helper'

describe OrderItem::ForPricing do
  Given(:item) { build :order_item_for_pricing }
  context 'it is readonly' do
    Then { expect { item.save! }.to raise_error(ActiveRecord::ReadOnlyRecord) }
    And { expect { item.save }.to raise_error(ActiveRecord::ReadOnlyRecord) }
  end
end
