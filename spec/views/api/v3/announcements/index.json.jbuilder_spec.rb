require 'spec_helper'

RSpec.describe 'api/v3/announcements/index.json.jbuilder', type: :view do
  let(:announcement) { create(:announcement) }

  it 'renders announcement' do
    assign(:announcements, [announcement])
    render
    expect(JSON.parse(rendered)).to eq(
      'announcements' => [{
        'id' => announcement.id,
        'message' => announcement.message
      }]
    )
  end
end
