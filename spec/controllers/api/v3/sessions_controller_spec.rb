require 'spec_helper'

describe Api::V3::SessionsController, :api_v3, type: :controller do
  context '#destroy' do
    context 'makes token unacceptable if user did sign in', signed_in: :normal do
      before do
        expect(token.acceptable?(:public)).to eq true
        expect(token.revoked_at).to be_nil
      end
      Given { delete :destroy, access_token: access_token }
      Then { expect(token.reload.revoked_at).not_to be_nil }
      And { expect(token.acceptable?(:public)).to eq false }
      And { expect(response).to render_template('api/v3/profiles/show') }
    end

    context 'returns 403 if user did not sign in', signed_in: false do
      Given { delete :destroy, access_token: access_token }
      Then { expect(response.status.to_i).to eq 403 }
      And { expect(token.reload.revoked_at).to be_nil }
    end

    context 'returns 403 if user is a guest', signed_in: :guest do
      Given { delete :destroy, access_token: access_token }
      Then { expect(response.status.to_i).to eq 403 }
      And { expect(token.reload.revoked_at).to be_nil }
    end
  end
end
