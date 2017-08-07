require 'spec_helper'

RSpec.describe 'api/v3/_announcement.json.jbuilder', :caching, type: :view do
  let(:announcement) { create(:announcement) }

  it 'renders announcement' do
    render 'api/v3/announcement', announcement: announcement
    expect(JSON.parse(rendered)).to eq(
      'id' => announcement.id,
      'message' => announcement.message
    )
  end
end
