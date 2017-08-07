require 'spec_helper'

describe Guanyi::ImportOrder do
  Given(:response) do
    {
      "code" => "SO13237214154",
      "platform_code" => "1601052102056CN",
      "receiver_name" => "呓 梦",
      "receiver_mobile" => "13331540405",
      "receiver_zip" => "131000",
      "receiver_address" => "China 吉林省长春市 吉林省长春市绿园区春草科技新村五栋六门115卢玉萍",
      "details" => [
        {
          "qty" => 2.0,
          "item_code" => "MUSCO1W42LB-1234-123",
          "item_name" => "马克杯",
          "platform_item_name" => "MUSCO1W42LB-0000-000",
        }
      ],
      "payments" => [
        {
          "payment" => 12.0,
        }
      ]
    }
  end
  Given(:trade_response) { Hashie::Mash.new(response) }
  Given!(:user) { create :user, email: 'guanyi@commandp.com' }
  Given(:import_order) { create :import_order }
  Given(:import) do
    user.reload
    Guanyi::ImportOrder.new(import_order)
  end

  context '#build_order' do
    context 'success' do
      Given(:work) { create :work }
      Given!(:work_code) { create :work_code, work: work, user_type: 'Designer', product_code: 'MUSCO1W42LB-1234-123' }
      before do
        Guanyi::Trade.any_instance.stub(:get_by_platform_code).and_return(trade_response)
        allow(import).to receive(:user).and_return(user)
      end
      When { import.send(:build_order, '1601052102056CN') }
      Given(:order) { Order.last }
      Then { import_order.succeeds.first.order == order }
      Then { import_order.succeeds.first.guanyi_trade_code == 'SO13237214154' }
      And { order.order_items.sum(:quantity) == 2 }
      And { order.shipping_info_address == "China 吉林省长春市 吉林省长春市绿园区春草科技新村五栋六门115卢玉萍" }
    end

    context 'ActiveRecord::RecordNotFound' do
      before do
        Guanyi::Trade.any_instance.stub(:get_by_platform_code).and_return(trade_response)
        allow(import).to receive(:user).and_return(user)
        allow(import).to receive(:platform_codes).and_return(['1601052102056CN'])
      end
      When { import.send(:build_order, '1601052102056CN') }
      Then { import.failed = [{ platform_code: '1601052102056CN', message: 'WorkNotFoundError' }] }
    end

    context 'ActiveRecord::RecordNotUnique' do
      Given!(:order) { create :order }
      before do
        Guanyi::Trade.any_instance.stub(:get_by_platform_code).and_return(trade_response)
        allow(import).to receive(:user).and_return(user)
        allow(import).to receive(:platform_codes).and_return(['1601052102056CN'])
        order.guanyi_trade_code = 'SO13237214154'
        order.save!
      end
      When { import.send(:build_order, '1601052102056CN') }
      Then { import.failed = [{ platform_code: '1601052102056CN', message: 'RecordExistedError' }] }
    end

    context 'GuanyiNotFoundError' do
      before do
        Guanyi::Trade.any_instance.stub(:get_by_platform_code).and_raise(GuanyiNotFoundError)
        allow(import).to receive(:platform_codes).and_return(['1601052102056CN'])
      end
      When { import.send(:build_order, '1601052102056CN') }
      Then { import.failed = [{ platform_code: '1601052102056CN', message: 'GuanyiNotFoundError' }] }
    end

    context 'GuanyiError' do
      before do
        Guanyi::Trade.any_instance.stub(:get_by_platform_code).and_raise(GuanyiError)
        allow(import).to receive(:platform_codes).and_return(['1601052102056CN'])
      end
      When { import.send(:build_order, '1601052102056CN') }
      Then { import.failed = [{ platform_code: '1601052102056CN', message: 'GuanyiError' }] }
    end
  end
end
