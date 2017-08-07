require 'spec_helper'

RSpec.describe Webhook::NewebController, type: :controller do
  context 'when request is valid' do
    context 'and order is exists' do
      before do
        CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
        CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
      end

      it 'updates order status' do
        order = create(:order, payment: 'neweb/atm')
        order.update_column :price, 502
        post :writeoff, generate_params(order)
        expect(response.status).to eq(200)
        order.reload
        expect(order.aasm_state).to eq('paid')
      end

      it 'updates order status with order_no is xxxxxx-2' do
        order = create(:order, payment: 'neweb/atm')
        params = generate_params(order, order_no: order.order_no+"-2")
        order.update_column :price, 502
        post :writeoff, params
        expect(response.status).to eq(200)
        order.reload
        expect(order.aasm_state).to eq('paid')
      end
    end

    context 'but order is not exists' do
      it 'does nothing' do
        post :writeoff, generate_params(double(order_no: 'blah'))
        expect(response.status).to eq(200)
      end
    end

    context 'when payment price conflicts' do
      it 'create paid_fail log and render nothing' do
        order = create(:order, payment: 'neweb/atm')
        order.update_column :price, 502
        params = generate_params(order).merge({ 'amount' => '100'})
        post :writeoff, params
        expect(response.status).to eq 200
        expect(order.reload.aasm_state).not_to eq 'paid'
        activity = order.activities.find_by(key: 'pay_conflict')
        expect(activity.message).to eq PaymentPriceConflictError.new.message
        expect(activity.extra_info[:payment_price].to_i).to eq 100
      end
    end
  end

  context 'when request is valid' do
    it 'does nothing' do
      post :writeoff, 'merchantnumber' => '459807'
      expect(response.status).to eq(200)
    end
  end


  def generate_params(order, opt = {})
    order_no = opt.delete(:order_no) || order.order_no
    params = {
      'merchantnumber' => '459807',
      'ordernumber' => order_no,
      'serialnumber' => '32',
      'writeoffnumber' => '09063071000001',
      'timepaid' => '20090630180121',
      'paymenttype' => 'ATM',
      'amount' => '502',
      'tel' => ''
    }
    params['hash'] = NewebService.new.write_off_hash(params)
    params
  end
end
