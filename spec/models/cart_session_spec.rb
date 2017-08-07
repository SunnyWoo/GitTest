# == Schema Information
#
# Table name: artworks
#
#  id          :integer          not null, primary key
#  model_id    :integer
#  uuid        :string(255)
#  name        :string(255)
#  description :text
#  work_type   :integer
#  finished    :boolean          default(FALSE)
#  featured    :boolean          default(FALSE)
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  user_id     :integer
#

require 'spec_helper'

RSpec.describe CartSession, type: :model do
  let(:user) { create(:user) }
  let(:work) { create(:work) }
  let(:coupon) { create(:coupon) }
  let(:order_info) {
      {
        memo: 'hi this is memo',
        models: ['case', 'mug', 'card'],
        images: [
          'http://placehold.it/100x100/333/fff',
          'http://placehold.it/200x200/333/fff',
          'http://placehold.it/300x300/333/fff'
        ]
      }
    }

  before do
    create_basic_currencies
    create(:fee, name: 'cash_on_delivery')
  end

  describe 'create with redis' do
    before do
      @mock_controller = double(current_currency_code: 'USD', current_country_code: 'US', session: {})
      @cart = CartSession.new(controller: @mock_controller, user_id: user.id)
    end

    it 'init' do
      expect(@cart.items).to eq({})
    end

    it 'add item and update itme' do
      @cart.add_items(work.to_gid, 1)
      @cart.update_items(work.to_gid, 3)
      @cart.add_items(work.to_gid, 1)
      @cart.save

      cart = CartSession.new(controller: @mock_controller, user_id: user.id)
      expect(cart.items[work.to_gid.to_s.to_sym]).to eq(4)
      expect(cart.items[work.to_gid.to_s.to_sym]).not_to eq('4')
      expect(cart.item_sum).to eq(4)
      expect(cart.item_sum).not_to eq('4')
    end

    it 'delete item' do
      work2 = create(:work)
      @cart.add_items(work.to_gid, 2)
      @cart.add_items(work2.to_gid, 3)
      @cart.delete_items(work2.to_gid)
      @cart.save

      cart = CartSession.new(controller: @mock_controller, user_id: user.id)
      expect(cart.items[work.to_gid.to_s.to_sym]).to be(2)
      expect(cart.items[work2.to_gid.to_s.to_sym]).to be nil
    end

    it 'apply_coupon_code' do
      @cart.apply_coupon_code(coupon.code)
      @cart.save

      cart = CartSession.new(controller: @mock_controller, user_id: user.id)
      expect(cart.build_tmp_order.coupon.code).to eq(coupon.code)
    end

    it 'clear_coupon_code' do
      @cart.apply_coupon_code(coupon.code)
      @cart.save
      @cart.clear_coupon_code
      @cart.save
      cart = CartSession.new(controller: @mock_controller, user_id: user.id)
      expect(cart.build_tmp_order.coupon).to eq(nil)
    end
    it 'update_check_out' do
      @cart.add_items(work.to_gid, 1)
      @cart.update_check_out(payment: 'paypal',
                             message: 'here is message',
                             order_info: order_info,
                             shipping_way: 'express',
                             shipping_info: {
                               name: 'Andy',
                               address: 'Zhongxiao Fuxing'
                             },
                             billing_info: {
                               name: 'Zoo',
                               address: 'Zhongxiao Fuxing 2'
                             })
      order = @cart.build_tmp_order
      expect(order.payment).to eq('paypal')
      expect(order.message).to eq('here is message')
      expect(order.order_info.to_json).to eq(order_info.to_json)
      expect(order.shipping_info.shipping_way).to eq('express')
      expect(order.shipping_info.name).to eq('Andy')
      expect(order.shipping_info.address).to eq('Zhongxiao Fuxing')
      expect(order.billing_info.name).to eq('Zoo')
      expect(order.billing_info.address).to eq('Zhongxiao Fuxing 2')
    end
  end

  context 'init with store' do
    Given(:mock_controller) {
      double(current_currency_code: 'USD', current_country_code: 'US', session: {})
    }
    Given(:store) { create(:store) }
    Given(:cart) do
      CartSession.new(controller: mock_controller, user_id: user.id, store_id: store.id)
    end
    Given(:cart_without_sotre_id) do
      CartSession.new(controller: mock_controller, user_id: user.id)
    end
    Given do
      cart.add_items(work.to_gid, 1)
      cart.save
    end
    Then { cart.items != {} }
    And { cart_without_sotre_id.items == {} }

    Given(:tmp_order) { cart.build_tmp_order }
    Then { tmp_order.source == 'shop' }
    And { tmp_order.channel.to_i == store.id }

    Given(:order) { cart.build_order }
    Then { order.source == 'shop' }
    And { order.channel.to_i == store.id }
  end

  context 'create with session' do
    before do
      mock_controller = double(current_currency_code: 'USD', current_country_code: 'US', session: {})
      @cart = CartSession.new(controller: mock_controller)
    end

    it 'init' do
      expect(@cart.items).to eq({})
    end

    it 'add item' do
      @cart.add_items(work.to_gid, 33)
      expect(@cart.items[work.to_gid.to_s.to_sym]).to eq(33)
    end

    it 'delete item' do
      work2 = create(:work)
      @cart.add_items(work.to_gid, 2)
      @cart.add_items(work2.to_gid, 3)
      @cart.delete_items(work2.to_gid)
      expect(@cart.items[work.to_gid.to_s.to_sym]).to be(2)
      expect(@cart.items[work2.to_gid.to_s.to_sym]).to be nil
    end

    it 'apply_coupon_code' do
      @cart.apply_coupon_code(coupon.code)
      expect(@cart.build_tmp_order.coupon.code).to eq(coupon.code)
    end

    it 'update_check_out' do
      @cart.update_check_out(payment: 'paypal',
                             shipping_way: 'express',
                             shipping_info: {
                               name: 'Andy',
                               address: 'Zhongxiao Fuxing'
                             },
                             billing_info: {
                               name: 'Zoo',
                               address: 'Zhongxiao Fuxing 2'
                             })
      order = @cart.build_tmp_order
      expect(order.payment).to eq('paypal')
      expect(order.shipping_info.shipping_way).to eq('express')
      expect(order.shipping_info.name).to eq('Andy')
      expect(order.shipping_info.address).to eq('Zhongxiao Fuxing')
      expect(order.billing_info.name).to eq('Zoo')
      expect(order.billing_info.address).to eq('Zhongxiao Fuxing 2')
    end
  end

  describe '#valid_coupon_code?' do
    let(:cart) do
      mock_controller = double(current_currency_code: 'USD', current_country_code: 'US', session: {})
      CartSession.new(controller: mock_controller)
    end

    context 'when coupon code is blank' do
      it 'returns false' do
        expect(cart.valid_coupon_code?('', user)).to be(false)
      end
    end

    context 'when coupon code is not found' do
      it 'returns false' do
        expect(cart.valid_coupon_code?('not found', user)).to be(false)
      end
    end

    context 'when coupon code cannot be used' do
      it 'returns false' do
        allow(Coupon).to receive(:find_by).and_return(double(:coupon, can_use?: false))
        expect(cart.valid_coupon_code?('coupon', user)).to be(false)
      end
    end

    context 'when coupon code condition is not pass for order' do
      it 'returns false' do
        allow(Coupon).to receive(:find_by).and_return(double(:coupon, can_use?: true, pass_condition?: false))
        expect(cart.valid_coupon_code?('coupon', user)).to be(false)
      end
    end

    context 'when coupon code condition is pass for order' do
      it 'returns true' do
        allow(Coupon).to receive(:find_by).and_return(double(:coupon, can_use?: true, pass_condition?: true))
        expect(cart.valid_coupon_code?('coupon', user)).to be(true)
      end
    end
  end

  context 'build_order' do
    let(:application) { double(id: 1) }
    let(:controller) do
      double(current_currency_code: 'USD',
             current_country_code: 'US',
             session: {},
             os_type: nil,
             remote_ip: nil,
             request: double(user_agent: nil),
             current_application: double(id: 1))
    end
    let(:tw_controller) do
      double(current_currency_code: 'TWD',
             current_country_code: 'TW',
             session: {},
             os_type: nil,
             remote_ip: nil,
             request: double(user_agent: nil),
             current_application: double(id: 1))
    end

    it 'build' do
      cart = CartSession.new(controller: controller)
      cart.add_items(work.to_gid, 2)
      cart.update_check_out(payment: 'paypal',
                            message: 'here is message',
                            order_info: order_info,
                            shipping_info: {
                              name: 'Andy',
                              address: 'Zhongxiao Fuxing',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            },
                            billing_info: {
                              name: 'Zoo',
                              address: 'Zhongxiao Fuxing 2',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            })
      order = cart.build_order
      order.save
      expect(order).to be_persisted
      expect(order.payment).to eq('paypal')
      expect(order.message).to eq('here is message')
      expect(order.order_info.to_json).to eq(order_info.to_json)
    end

    it 'build with store_id' do
      store = create(:store, name: '正宗。商店')
      user = create(:user, id: 999)
      cart = CartSession.new(controller: controller, user_id: user.id, store_id: store.id)
      cart.add_items(work.to_gid, 2)
      cart.update_check_out(payment: 'cash_on_delivery',
                            shipping_info: {
                              name: 'Andy',
                              address: 'Zhongxiao Fuxing',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            },
                            billing_info: {
                              name: 'Zoo',
                              address: 'Zhongxiao Fuxing 2',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            })
      cart.save
      order = cart.build_order
      expect(order).to be_shop
      expect(order.channel).to eq store.id.to_s
    end

    it 'build with user_id' do
      user = create(:user, id: 999)
      cart = CartSession.new(controller: controller, user_id: user.id)
      cart.add_items(work.to_gid, 2)
      cart.apply_coupon_code(coupon.code)
      cart.update_check_out(payment: 'cash_on_delivery',
                            shipping_info: {
                              name: 'Andy',
                              address: 'Zhongxiao Fuxing',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            },
                            billing_info: {
                              name: 'Zoo',
                              address: 'Zhongxiao Fuxing 2',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            })
      tmp_order = cart.build_tmp_order
      cart.save

      cart = CartSession.new(controller: controller, user_id: user.id)
      order = cart.build_order
      order.save
      cart.clean(order)
      cart.save

      expect(order).to be_persisted
      expect(order.payment).to eq('cash_on_delivery')
      expect(order.user_id).to eq(user.id)
      expect(order.price).to eq(tmp_order.price)
      expect(order.coupon.code).to eq(coupon.code)
      expect(order.discount).to eq(coupon.price(order.currency))

      # check clean cart
      cart = CartSession.new(controller: controller, user_id: user.id)
      expect(cart.cart).to eq(cart.default_cart)
    end

    it 'raises CartIsEmptyError if items is empty' do
      cart = CartSession.new(controller: controller)
      cart.update_check_out(payment: 'paypal',
                            shipping_info: {
                              name: 'Andy',
                              address: 'Zhongxiao Fuxing',
                              email: Faker::Internet.email
                            },
                            billing_info: {
                              name: 'Zoo',
                              address: 'Zhongxiao Fuxing 2',
                              email: Faker::Internet.email
                            })
      expect { cart.build_order }.to raise_error(CartIsEmptyError)
    end

    it 'change current_currency_code to TWD' do
      user = create(:user, id: 999)
      cart = CartSession.new(controller: controller, user_id: user.id)
      cart.add_items(work.to_gid, 2)
      cart.update_check_out(payment: 'paypal',
                            message: 'here is message',
                            shipping_info: {
                              name: 'Andy',
                              address: 'Zhongxiao Fuxing',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            },
                            billing_info: {
                              name: 'Zoo',
                              address: 'Zhongxiao Fuxing 2',
                              email: Faker::Internet.email,
                              country_code: 'TW',
                              phone: '0228825252'
                            })
      cart.save
      tmp_order = cart.build_tmp_order
      expect(tmp_order.currency).to eq('USD')
      expect(tmp_order.price).to eq(199.8)

      cart = CartSession.new(controller: tw_controller, user_id: user.id)
      order = cart.build_order
      order.calculate_price!
      cart.clean(order)
      cart.save

      expect(order.currency).to eq('TWD')
      expect(order.price).to eq(5998.0)
      expect(order.order_items.first.itemable.to_gid).to eq(work.to_gid)
      expect(order.shipping_info.address).to eq('Zhongxiao Fuxing')
    end
  end
end
