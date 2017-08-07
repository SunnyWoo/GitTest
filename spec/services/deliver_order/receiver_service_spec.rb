require 'spec_helper'

describe DeliverOrder::ReceiverService do
  context 'deliver order from global to china' do
    context '#create' do
      before { stub_env('REGION', 'china') }
      Given!(:deliver_user) { create :user, :without_confirmed, email: 'deliverorder@commandp.com' }
      Given!(:product_model) { create :product_model, key: 'iphone_4_cases' }
      Given!(:product_model_iphone_5) { create :product_model, key: 'iphone_5_cases' }
      Given!(:currency) { create :currency, code: 'CNY' }
      Given(:query) do
        {
          'order_id' => 48,
          'order_no' => '1578000269TW',
          'payment' => 'paypal',
          'order_items' => [
            {
              'item_id' => 76,
              'quantity' => 2,
              'itemable_type' => 'ArchivedWork',
              'work' => {
                'remote_product_key' => 'iphone_4_cases',
                'cover_image' => '',
                'print_image' => '',
                'name' => 'My Design'
              }
            },
            {
              'item_id' => 77,
              'quantity' => 2,
              'itemable_type' => 'ArchivedStandardizedWork',
              'work' => {
                'remote_product_key' => 'iphone_5_cases',
                'cover_image' => '',
                'print_image' => '',
                'order_image' => '',
                'name' => 'My Design'
              }
            }
          ],
          'single_item' => true
        }
      end
      Given(:service) { DeliverOrder::ReceiverService.new(query) }
      context 'create order' do
        before { create :coupon, code: 'COMMANDPTW' }
        When { service.create }
        Given(:new_order) { Order.last }
        Then { new_order.remote_id == 48 }
        And { RepairImagesWorker.jobs.empty? }
        And { new_order.remote_info['order_no'] == '1578000269TW' }
        And { new_order.remote_info['single_item'] == true }
        And { new_order.order_items.count == 2 }
        And { new_order.order_items.sum(:quantity) == 4 }
        And { new_order.order_items.pluck(:remote_id).sort == [76, 77] }
        And { new_order.aasm_state == 'paid' }
        And { new_order.approved == true }
        And { new_order.currency == 'CNY' }
        And { new_order.subtotal.to_f == product_model.prices.to_h['CNY'] * 4 }
        And { new_order.discount.to_f == 30.0 }
        And { new_order.order_items.pluck(:itemable_type).sort == %w(ArchivedWork ArchivedStandardizedWork).sort }
        And { ArchivedWork.pluck(:model_id) == [product_model.id] }
        And { ArchivedStandardizedWork.pluck(:model_id) == [product_model_iphone_5.id] }
        Given(:aw) { ArchivedWork.find_by(product: product_model) }
        And { aw.product_code == "#{product_model.code}-0001-000" }
      end
    end
  end

  context 'deliver order from china to global' do
    before { stub_env('REGION', 'global') }
    Given!(:deliver_user) { create :user, :without_confirmed, email: 'deliverorder@commandp.com' }
    Given!(:product_model) { create :product_model, key: 'iphone_4_cases' }
    Given!(:product_model_iphone_5) { create :product_model, key: 'iphone_5_cases' }
    Given!(:currency) { create :currency, code: 'CNY' }
    Given(:query) do
      {
        'order_id' => 48,
        'order_no' => '1578000269TW',
        'payment' => 'paypal',
        'order_items' => [
          {
            'item_id' => 76,
            'quantity' => 2,
            'itemable_type' => 'ArchivedWork',
            'work' => {
              'remote_product_key' => 'iphone_4_cases',
              'cover_image' => '',
              'print_image' => '',
              'name' => 'My Design'
            }
          },
          {
            'item_id' => 77,
            'quantity' => 2,
            'itemable_type' => 'ArchivedStandardizedWork',
            'work' => {
              'remote_product_key' => 'iphone_5_cases',
              'cover_image' => '',
              'print_image' => '',
              'order_image' => '',
              'name' => 'My Design'
            }
          }
        ],
        'single_item' => true
      }
    end
    Given(:service) { DeliverOrder::ReceiverService.new(query) }
    context 'create order' do
      before { create :coupon, code: 'COMMANDPTW' }
      When { service.create }
      Given(:new_order) { Order.last }
      Then { new_order.remote_id == 48 }
      And { RepairImagesWorker.jobs.empty? }
      And { new_order.remote_info['order_no'] == '1578000269TW' }
      And { new_order.remote_info['single_item'] == true }
      And { new_order.order_items.count == 2 }
      And { new_order.order_items.sum(:quantity) == 4 }
      And { new_order.order_items.pluck(:remote_id).sort == [76, 77] }
      And { new_order.aasm_state == 'paid' }
      And { new_order.approved == true }
      And { new_order.currency == 'TWD' }
      And { new_order.subtotal.to_f == product_model.prices.to_h['TWD'] * 4 }
      And { new_order.discount.to_f == 150.0 }
      And { new_order.order_items.pluck(:itemable_type).sort == %w(ArchivedWork ArchivedStandardizedWork).sort }
      And { ArchivedWork.pluck(:model_id) == [product_model.id] }
      And { ArchivedStandardizedWork.pluck(:model_id) == [product_model_iphone_5.id] }
      Given(:aw) { ArchivedWork.find_by(product: product_model) }
      And { aw.product_code == "#{product_model.code}-0001-000" }
    end

    context 'create order when COMMANDPTW coupon code not exist' do
      When { service.create }
      Then { Order.last.coupon.nil? }
    end

    context 'create order when coupon condition is not satisfied' do
      Given(:product_model_not_exist_in_order_items) { create :product_model, key: 'not_exist' }
      before {
        create :coupon, code: 'COMMANDPTW',
                        condition: 'rules',
                        coupon_rules: [create(:product_model_rule, product_model_ids: [product_model_not_exist_in_order_items.id])]
      }
      When { service.create }
      Given(:new_order) { Order.last }
      Then { new_order.coupon.nil? }
      And { new_order.discount.to_f == 0.0 }
      And { new_order.embedded_coupon.nil? }
    end

    context 'image upload error' do
      Given(:error_query) do
        {
          'order_id' => 48,
          'order_no' => '1578000269TW',
          'payment' => 'paypal',
          'order_items' => [
            {
              'item_id' => 76,
              'quantity' => 2,
              'itemable_type' => 'ArchivedWork',
              'work' => {
                'remote_product_key' => 'iphone_4_cases',
                'cover_image' => 'error',
                'print_image' => 'error',
                'name' => 'My Design'
              }
            },
            {
              'item_id' => 77,
              'quantity' => 2,
              'itemable_type' => 'ArchivedStandardizedWork',
              'work' => {
                'remote_product_key' => 'iphone_5_cases',
                'cover_image' => '',
                'print_image' => 'error',
                'order_image' => '',
                'name' => 'My Design'
              }
            }
          ]
        }
      end
      Given(:service) { DeliverOrder::ReceiverService.new(error_query) }
      before { create :coupon, code: 'COMMANDPTW' }
      When { service.create }
      Given(:new_order) { Order.last }
      Then { new_order.remote_id == 48 }
      And { RepairImagesWorker.jobs.size == 2 }
      And { new_order.deliver_error_collections.size == 2 }
      Given(:aw_error_collection) { new_order.deliver_error_collections.find_by(workable_type: 'ArchivedWork') }
      And { aw_error_collection.error_messages.keys.sort == %w(cover_image print_image) }
      And { aw_error_collection.cover_image_url == 'error' }
      And { aw_error_collection.print_image_url == 'error' }
      Given(:asw_error_collection) { new_order.deliver_error_collections.find_by(workable_type: 'ArchivedStandardizedWork') }
      And { asw_error_collection.error_messages.keys == ['print_image'] }
      And { asw_error_collection.print_image_url == 'error' }
    end

    context 'only ArchivedWork print image upload error' do
      Given(:print_image_error_query) do
        {
          'order_id' => 48,
          'order_no' => '1578000269TW',
          'payment' => 'paypal',
          'order_items' => [
            {
              'item_id' => 76,
              'quantity' => 2,
              'itemable_type' => 'ArchivedWork',
              'work' => {
                'remote_product_key' => 'iphone_4_cases',
                'cover_image' => '',
                'print_image' => 'error',
                'name' => 'My Design'
              }
            },
            {
              'item_id' => 77,
              'quantity' => 2,
              'itemable_type' => 'ArchivedStandardizedWork',
              'work' => {
                'remote_product_key' => 'iphone_5_cases',
                'cover_image' => '',
                'print_image' => '',
                'order_image' => '',
                'name' => 'My Design'
              }
            }
          ]
        }
      end
      Given(:service) { DeliverOrder::ReceiverService.new(print_image_error_query) }
      before { create :coupon, code: 'COMMANDPTW' }
      When { service.create }
      Given(:new_order) { Order.last }
      Then { new_order.remote_id == 48 }
      And { new_order.deliver_error_collections.size == 1 }
      And { RepairImagesWorker.jobs.size == 1 }
      Given(:aw_error_collection) { new_order.deliver_error_collections.find_by(workable_type: 'ArchivedWork') }
      And { aw_error_collection.error_messages.keys == ['print_image'] }
      And { aw_error_collection.print_image_url == 'error' }
      And { aw_error_collection.cover_image_url.blank? }
      And { aw_error_collection.order_item.remote_id == 76 }
    end
  end
end
