require 'rails_helper'
require 'spec_helper'

RSpec.describe Payment::PingppAlipayQrController, type: :controller do
  before do
    sign_in create(:user)
    CurrencyType.create(name: 'CNY', code: 'CNY', rate: 5)
  end
  Given(:work) { create(:work) }
  Given(:cart_session) do
    {
      currency: 'CNY',
      payment: 'pingpp_alipay_qr',
      billing_info: {
        country_code: 'CN',
        email: 'test@commandp.me',
        phone: '0228825252',
        address: 'Attack Here!'
      },
      items: [[work.to_gid.to_s, 1]]
    }
  end
  Given(:pending_order) { create(:pending_order, :priced, payment_method: 'pingpp_alipay_qr', currency: 'CNY') }
  Given(:paid_order) { create(:paid_order, payment_method: 'pingpp_alipay_qr', currency: 'CNY') }
  Given(:pingpp) { YAML.load(File.read("#{Rails.root}/spec/fixtures/pingpp_object.yml")) }

  describe '#begin' do
    before { allow(Pingpp::Charge).to receive(:create).and_return(pingpp) }
    context 'when not provides order_no' do
      When { post :begin, { locale: 'zh-CN' }, cart: cart_session }
      Given(:order) { Order.last }
      Then { order.pending? }
      And { order.payment_id.nil? }
      And { response.status == 200 }
    end

    context 'when provides order_no' do
      When { post :begin, locale: 'zh-CN', order_no: pending_order.order_no }
      Then { pending_order.reload.pending? }
      And { pending_order.reload.payment_id.nil? }
      And { response.status == 200 }
    end

    context 'and order is not found' do
      When { post :begin, locale: 'zh-CN', order_no: 'nothisorderno' }
      Then { response.status == 404 }
    end
  end

  describe '#pay_result' do
    context 'when order is paid' do
      When { get :pay_result, locale: 'zh-CN', order_no: paid_order.order_no, format: :json }

      Then { response_json['paid'] == true }
    end

    context 'when order is not paid' do
      When { get :pay_result, locale: 'zh-CN', order_no: pending_order.order_no, format: :json }

      Then { response_json['paid'] == false }
    end
  end
end
