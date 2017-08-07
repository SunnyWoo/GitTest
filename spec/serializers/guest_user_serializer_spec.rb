require 'spec_helper'

describe GuestUserSerializer do
  it 'works' do
    user = User.new_guest
    json = JSON.parse(GuestUserSerializer.new(user).to_json)
    expect(json).to eq({
      'guest_user' => {
        'user_id' => user.id,
        'auth_token' => user.auth_token
      }
    })
  end
end
