require 'spec_helper'

RSpec.describe 'api/v3/attachments/show.json.jbuilder', :caching, type: :view do
  let(:attachment) { create(:attachment, file: File.open('spec/fixtures/great-design.jpg')) }

  it 'renders attachment', :freeze_time do
    assign(:attachment, attachment)
    render
    expect(JSON.parse(rendered)).to eq(
      'attachment' => {
        'id' => attachment.aid,
        'url' => attachment.file.url,
        'content_type' => attachment.content_type,
        'size' => attachment.size,
        'md5sum' => attachment.md5sum,
        'width' => attachment.width,
        'height' => attachment.height
      }
    )
  end
end
