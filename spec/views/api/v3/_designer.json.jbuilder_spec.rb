require 'spec_helper'

RSpec.describe 'api/v3/_designer.json.jbuilder', :caching, type: :view do
  let(:designer) { create(:designer) }

  it 'renders designer' do
    render 'api/v3/designer', designer: designer
    expect(JSON.parse(rendered)).to eq(
      'id' => designer.id,
      'display_name' => designer.display_name
    )
  end
end
