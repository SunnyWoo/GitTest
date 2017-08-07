require 'spec_helper'

RSpec.describe 'api/v3/_work_output_file.json.jbuilder', :caching, type: :view do
  let(:work_output_file) { create(:work_output_file) }

  it 'renders work_output_file' do
    render 'api/v3/work_output_file', output_file: work_output_file
    expect(JSON.parse(rendered)).to eq(
      'id' => work_output_file.id,
      'key' => work_output_file.key,
      'file_url' => work_output_file.file.url
    )
  end
end
