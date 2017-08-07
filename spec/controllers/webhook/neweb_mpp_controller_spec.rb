require 'spec_helper'

RSpec.describe Webhook::NewebMppController, type: :controller do
  context 'when request is valid' do
    context 'and order is exists' do
      before do
        CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
        CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
      end

      it 'updates order status' do
        order = create(:order, payment: 'neweb_mpp')
        post :writeoff, generate_params(order)
        expect(response.status).to eq(200)
        order.reload
        expect(order.aasm_state).to eq('paid')
      end

      it 'updates order status with order_no is xxxxxx-2' do
        order = create(:order, payment: 'neweb_mpp')
        post :writeoff, generate_params(order, order_no: "#{order.order_no}-2")
        expect(response.status).to eq(200)
        order.reload
        expect(order.aasm_state).to eq('paid')
      end
    end

    context 'but order is not exists' do
      it 'does nothing' do
        post :writeoff, generate_params(double(order_no: 'blah', price: 222))
        expect(response.status).to eq(200)
      end
    end
  end

  context 'when request is valid' do
    it 'does nothing' do
      post :writeoff, 'merchantnumber' => '459807'
      expect(response.status).to eq(200)
    end
  end


  context 'when payment price conflicts' do
    it 'create paid_fail log' do
        order = create(:order, payment: 'neweb_mpp')
        order.update_column :price, 1000
        params = generate_params(order, order_no: "#{order.order_no}-2").
                                merge({ 'Amount' => '200' })
        post :writeoff, params
        expect(response.status).to eq(200)
        expect(order.reload.aasm_state).not_to eq 'paid'
        acitivity = order.activities.find_by(key: :pay_conflict)
        expect(acitivity.message).to eq(PaymentPriceConflictError.new.message)
        expect(acitivity.extra_info[:payment_price].to_i).to eq 200
      end
  end

  def generate_params(order, opt = {})
    order_no = opt.delete(:order_no) || order.order_no
    params = {
      'MerchantNumber' => '459807',
      'OrderNumber'    => order_no,
      'PRC'            => '0',
      'SRC'            => '0',
      'Amount'         => order.price
    }
    neweb = NewebMPPService.new
    params['CheckSum'] = neweb.md5('459807', order_no, '0', '0', neweb.code, order.price)
    params
  end
end
