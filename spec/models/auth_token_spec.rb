# == Schema Information
#
# Table name: auth_tokens
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  token      :string(255)
#  extra_info :json
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe AuthToken do
  it { build(:auth_token).valid? } # FactoryGirl
  it { should validate_presence_of(:user_id) }

  context '#generate_token' do
    Given(:uuid) { '0ef657d2-d53c-11e5-bc1a-a0999b0937d3' }
    Given(:token) { uuid.delete('-') }

    context 'generate token by UUIDTools::UUID' do
      before { allow(UUIDTools::UUID).to receive(:timestamp_create).and_return(uuid) }
      When { AuthToken.create(user_id: 4) }
      Then { AuthToken.last.token == token }
    end

    context 'trigerred by before_validation' do
      Given(:auth_token) { AuthToken.new }
      before { expect(auth_token).to receive(:generate_token) }
      Then { auth_token.valid? == false }
    end

    context 'skip generate token if it is assigned' do
      Given(:auth_token) { AuthToken.new(token: token) }
      before { expect(UUIDTools::UUID).not_to receive(:timestamp_create) }
      Then { auth_token.valid? == false }
    end
  end

  context '.authenticate' do
    context 'throw ActiveRecord::RecordNotFound when not authenticated' do
      Then { expect { AuthToken.authenticate('not_found') }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'give the auth_token.user back' do
      Given(:auth_token) { create(:auth_token) }
      Then { AuthToken.authenticate(auth_token.token) == auth_token.user }
    end
  end
end
