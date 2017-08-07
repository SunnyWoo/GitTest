require 'rails_helper'

Temping.create :dummy_class do
  with_columns do |t|
    t.string :file
    t.json :file_meta
  end
  include HasAttachment
  extend CarrierWave::Meta::ActiveRecord
  serialize :file_meta, Hashie::Mash.pg_json_serializer
  mount_uploader :file, DefaultWithMetaUploader
  carrierwave_meta_composed :file_meta, :file, image_version: [:content_type, :size, :width, :height, :md5sum]
  has_attachment :file
end

describe HasAttachment do
  let(:dummy) { DummyClass.create }
  let(:attachment) { create(:attachment) }
  let(:attachment_aid) { attachment.aid }

  it 'provides file_aid= method' do
    dummy.file_aid = attachment_aid
    expect(dummy.attachments[:file]).to eq(attachment_aid)
  end

  it 'reads attachment and store in uploader' do
    dummy.update(file_aid: attachment_aid)
    expect(dummy.file_meta.file_md5sum).to eq(attachment.file_meta.file_md5sum)
    expect(dummy.file.md5sum).to eq(attachment.file.md5sum)
  end

  it 'does nothing if aid is nil' do
    dummy.update(file_aid: attachment_aid)
    dummy.update(file_aid: nil)
    expect(dummy.file).not_to be_blank
  end
end
