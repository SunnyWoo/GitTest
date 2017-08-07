require 'spec_helper'

RSpec.describe 'api/v3/_activity.json.jbuilder', :caching, type: :view do
  let(:activity) do
    Logcraft::Activity.create
  end

  it 'renders activity' do
    render 'api/v3/activity', activity: activity
    expect(JSON.parse(rendered)).to eq(
      'key' => activity.key,
      'created_at' => activity.created_at.as_json
    )
  end
end
