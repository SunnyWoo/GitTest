require 'spec_helper'

RSpec.describe 'api/v2/admin/omniauths/show.json.jbuilder', type: :view do
  let(:auth) { create(:omniauth) }

  it 'renders auth' do
    assign(:omniauth, auth)
    render
    expect(JSON.parse(rendered)).to eq(
      'omniauth' => {
        'provider' => auth.provider,
        'uid' => auth.uid,
        'oauth_token' => auth.oauth_token,
        'owner_id' => auth.owner_id,
        'owner_type' => auth.owner_type
      }
    )
  end
end
