require 'spec_helper'

describe NuandaoWebhookService::OrderShipping do
  let(:order) { create(:paid_order) }

  context '#execute' do
    let(:service_response) { "{\"status\":\"ok\"}" }
    before do
      order.update_attribute(:payment_id, '123456')
      stub_request(:post, Settings.nuandao_b2b.order_shipping_url).
        to_return(status: 200, body: service_response)
    end

    context 'when service responds with ok' do
      it 'creates "nuandao_webhook_order_shipping" activity and result is true' do
        expect(NuandaoWebhookService::OrderShipping.new(order.id).execute).to be(true)
        activity = order.activities.last
        expect(activity.key).to eq('nuandao_webhook_order_shipping')
        expect(activity.extra_info.result).to eq(true)
      end
    end

    context 'when service responds with fail' do
      let(:service_response) { "{\"status\":\"false\"}" }
      it 'creates "nuandao_webhook_order_shipping" activity and result is false' do
        expect(NuandaoWebhookService::OrderShipping.new(order.id).execute).to be(false)
        activity = order.activities.last
        expect(activity.key).to eq('nuandao_webhook_order_shipping')
        expect(activity.extra_info.result).to eq(false)
      end
    end
  end
end
