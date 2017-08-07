require 'spec_helper'

describe Print::OrderItemsController, type: :request do
  before(:each) { login_factory_member }

  context 'index' do
    it 'check order_item.timestamp_no' do
      # order = create(:order)
      # create_list(:order_item, 2, order: order)
      # order.pay!
      # order.reload
      # order.order_items.each{ |order_item| order_item.clone_to_print_items }
      # print_item_1 = order.print_items.pending.first
      # product_model = print_item_1.model
      # get print_order_items_path, { product_model_id: product_model.id, last_id: print_item_1.id }
      # print_item_1.reload
      # expect(print_item_1.timestamp_no).not_to be nil
      # print_item_2 = order.print_items.pending.first
      # product_model = print_item_2.model
      # login_factory
      # get print_order_items_path, { product_model_id: product_model.id, last_id: print_item_2.id }
      # print_item_2.reload
      # expect(print_item_2.timestamp_no).to eq( print_item_1.timestamp_no.to_i+1 )
      # expect(order.order_items.pending.size).to eq(1)
    end
  end
end
