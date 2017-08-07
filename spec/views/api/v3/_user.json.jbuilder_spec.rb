require 'spec_helper'

RSpec.describe 'api/v3/_user', :caching, type: :view do
  let(:user) do
    create(:user, avatar: File.open('spec/fixtures/test.jpg'),
                  background: File.open('spec/fixtures/great-design.jpg'))
  end

  it 'renders user' do
    assign(:user, user)
    render 'api/v3/user', user: user
    expect(JSON.parse(rendered)).to eq(
      'id' => user.id,
      'name' => user.name,
      'avatars' => {
        's35' => user.avatar.s35.url,
        's114' => user.avatar.s114.url,
        's154' => user.avatar.s154.url
      },
      'avatar_url' => user.avatar.url,
      'background_url' => user.background.url,
      'gender' => user.gender,
      'location' => user.location,
      'works_count' => user.works.finished.count,
      'role' => user.role
    )
  end
end
