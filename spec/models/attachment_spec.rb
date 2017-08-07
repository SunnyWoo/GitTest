# == Schema Information
#
# Table name: attachments
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  file_meta  :json
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Attachment, type: :model do
  describe '#aid' do
    it 'generates an unique id for attachment' do
      attachment = create(:attachment)
      expect(attachment.aid).to be_a(String)
    end

    it 'is locatable' do
      attachment = create(:attachment)
      expect(Attachment.find_by_aid(attachment.aid)).to eq(attachment)
    end

    it 'rasies an error when record not found with bang version' do
      expect { Attachment.find_by_aid!('attachment.aid') }.to raise_error RecordNotFoundError
    end
  end

  describe '#remote_file_url' do
    context 'it supports data url' do
      # 1x1 blank png
      Given(:data_url) do
        %w(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAA
           AC0lEQVQIW2NkAAIAAAoAAggA9GkAAAAASUVORK5CYII=).join
      end
      When(:attachment) { create(:attachment, remote_file_url: data_url) }
      Then { attachment.valid? }
      And { attachment.file.present? }
      And { attachment.file.width == 1 }
      And { attachment.file.height == 1 }
    end
  end
end
