require 'spec_helper'

RSpec.describe 'api/v3/_attachment.json.jbuilder', :caching, type: :view do
  let(:attachment) { create(:attachment, file: File.open('spec/fixtures/great-design.jpg')) }

  it 'renders attachment', :freeze_time do
    render 'api/v3/attachment', attachment: attachment
    expect(JSON.parse(rendered)).to eq(
      'id' => attachment.aid,
      'url' => attachment.file.url,
      'content_type' => attachment.content_type,
      'size' => attachment.size,
      'md5sum' => attachment.md5sum,
      'width' => attachment.width,
      'height' => attachment.height
    )
  end
end
