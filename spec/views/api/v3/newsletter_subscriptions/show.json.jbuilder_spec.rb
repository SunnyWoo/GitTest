require 'spec_helper'

RSpec.describe 'api/v3/newsletter_subscriptions/show.json.jbuilder', :caching, type: :view do
  let(:newsletter_subscription) { create(:newsletter_subscription) }

  it 'renders newsletter subscription' do
    assign(:newsletter_subscription, newsletter_subscription)
    render
    expect(JSON.parse(rendered)).to eq(
      'newsletter_subscription' => {
        'id' => newsletter_subscription.id,
        'email' => newsletter_subscription.email
      }
    )
  end
end
