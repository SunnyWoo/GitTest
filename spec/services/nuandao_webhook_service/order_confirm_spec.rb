require 'spec_helper'

describe NuandaoWebhookService::OrderConfirm do
  let(:order) { create(:order) }

  context '#initialize' do
    let(:paid_order) { create(:paid_order) }

    it 'return error when order not found' do
      expect{ NuandaoWebhookService::OrderConfirm.new(9999) }.
        to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'return error when order aasm_state id paid' do
      expect{ NuandaoWebhookService::OrderConfirm.new(paid_order.id) }.
        to raise_error(ApplicationError, /Order aasm_state must be pending/)
    end

    it 'return error when order payment is null' do
      expect{ NuandaoWebhookService::OrderConfirm.new(order.id) }.
        to raise_error(ApplicationError, 'Payment id is null')
    end
  end

  context '#execute' do
    let(:service_response) { "{\"status\":\"ok\"}" }
    before do
      order.update_attribute(:payment_id, '123456')
      stub_request(:post, Settings.nuandao_b2b.order_confirm_url).
        to_return(status: 200, body: service_response)
    end

    context 'when service responds with ok' do
      it 'creates "nuandao_webhook_order_confirm" activity and result is true' do
        expect(NuandaoWebhookService::OrderConfirm.new(order.id).execute).to be(true)
        activity = order.activities.last
        expect(activity.key).to eq('nuandao_webhook_order_confirm')
        expect(activity.extra_info.result).to eq(true)
      end
    end

    context 'when service responds with fail' do
      let(:service_response) { "{\"status\":\"false\"}" }
      it 'creates "nuandao_webhook_order_confirm" activity and result is false' do
        expect(NuandaoWebhookService::OrderConfirm.new(order.id).execute).to be(false)
        activity = order.activities.last
        expect(activity.key).to eq('nuandao_webhook_order_confirm')
        expect(activity.extra_info.result).to eq(false)
      end
    end
  end
end
