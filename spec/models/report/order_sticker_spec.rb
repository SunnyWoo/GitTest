# == Schema Information
#
# Table name: daily_records
#
#  id         :integer          not null, primary key
#  type       :string
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  target_ids :integer          default([]), is an Array

require 'spec_helper'

describe Report::OrderSticker, type: :model do
  context '#validate_create_once_for_a_day' do
    context 'for the first record' do
      When { create 'report/order_sticker' }
      Then { Report::OrderSticker.count == 1 }
    end

    context 'for the second record not in the same day' do
      before { create 'report/order_sticker', created_at: DateTime.current.yesterday }
      When { create 'report/order_sticker' }
      Then { Report::OrderSticker.count == 2 }
    end

    context 'for the second record in the same day' do
      before { create 'report/order_sticker' }
      When(:order_sticker) { build 'report/order_sticker' }
      Then { order_sticker.invalid? }
    end
  end

  context 'order_items_count' do
    Given(:work_item) { create :order_item, quantity: 3 }
    Given(:standardized_work_item) { create :order_item, :with_standardized_work, quantity: 2 }
    # order剛建立的時候，就帶有一個quantity: 1, itemable: Work的order_item
    Given(:order) { create :paid_order, order_items: [work_item, standardized_work_item] }
    Given!(:order_sticker) { create 'report/order_sticker', target_ids: [order.id] }

    context '#sold_customized_order_items_count' do
      Then { order_sticker.sold_customized_order_items_count == 4 }
    end

    context '#sold_designer_order_items_count' do
      Then { order_sticker.sold_designer_order_items_count == 2 }
    end
  end
end
