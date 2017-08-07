require 'spec_helper'

describe CancelOrderWorker do
  it '#perform' do
    order = create(:order)
    CancelOrderWorker.new.perform(order.id)
    order.tap(&:reload)
    expect(order.activities.where(key: 'cancel_order').count).to eq(1)
  end
end
