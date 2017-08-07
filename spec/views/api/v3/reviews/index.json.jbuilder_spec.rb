require 'spec_helper'

RSpec.describe 'api/v3/reviews/index.json.jbuilder', type: :view do
  let(:review) { create(:review) }

  it 'renders review' do
    assign(:reviews, [review])
    render
    expect(JSON.parse(rendered)).to eq(
      'reviews' => [{
        'user' => {
          'id' => review.user.id,
          'name' => review.user.name,
          'avatars' => {
            's35' => review.user.avatar.s35.url,
            's114' => review.user.avatar.s114.url,
            's154' => review.user.avatar.s154.url
          },
          'avatar_url' => review.user.avatar.url,
          'background_url' => review.user.background.url,
          'gender' => review.user.gender,
          'location' => review.user.location,
          'works_count' => review.user.works.finished.count,
          'role' => review.user.role
        },
        'user_id' => review.user_id,
        'user_name' => Monads::Optional.new(review).user.name.value,
        'user_avatar' => Monads::Optional.new(review).user.avatar.url.value,
        'body' => review.body,
        'star' => review.star,
        'created_at' => review.created_at.as_json
      }],
      'meta' => {
        'reviews_count' => 1
      }
    )
  end
end
