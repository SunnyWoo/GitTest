RSpec.shared_context 'when user is not signed in', signed_in: false do
  let(:scope) { 'public' }
  let(:token) { create(:access_token, scopes: scope) }
  let(:access_token) { token.token }
end

RSpec.shared_context 'when user is signed in as guest', signed_in: :guest do
  let(:scope) { 'public' }
  let(:user) { User.new_guest }
  let(:token) { create(:access_token, resource_owner_id: user.id, scopes: scope) }
  let(:access_token) { token.token }
end

RSpec.shared_context 'when user is signed in', signed_in: :normal do
  let(:scope) { 'public' }
  let(:user) { create(:user) }
  let(:token) { create(:access_token, resource_owner_id: user.id, scopes: scope) }
  let(:access_token) { token.token }
end

RSpec.shared_context 'api v3', api_v3: true do
  before { @request.env.merge! api_header(3) }
end

RSpec.shared_context 'admin', admin: true do
  I18n.locale = 'zh-TW'
  let(:admin) { create :admin }
  before do
    allow(controller).to receive(:set_locale).and_return(true)
    allow(controller).to receive(:check_require_action).and_return(true)
    sign_in admin
  end
end
