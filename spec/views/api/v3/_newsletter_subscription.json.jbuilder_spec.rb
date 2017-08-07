require 'spec_helper'

RSpec.describe 'api/v3/_newsletter_subscription.json.jbuilder', :caching, type: :view do
  let(:newsletter_subscription) { create(:newsletter_subscription) }

  it 'renders newsletter_subscription' do
    render 'api/v3/newsletter_subscription', newsletter_subscription: newsletter_subscription
    expect(JSON.parse(rendered)).to eq(
      'id' => newsletter_subscription.id,
      'email' => newsletter_subscription.email
    )
  end
end
