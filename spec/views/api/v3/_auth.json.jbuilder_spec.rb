require 'spec_helper'

RSpec.describe 'api/v3/_auth.json.jbuilder', :caching, type: :view do
  let(:auth) { create(:omniauth) }

  it 'renders auth' do
    render 'api/v3/auth', auth: auth
    expect(JSON.parse(rendered)).to eq(
      'provider' => auth.provider,
      'uid' => auth.uid,
      'oauth_token' => auth.oauth_token,
      'owner_id' => auth.owner_id,
      'owner_type' => auth.owner_type
    )
  end
end
