# == Schema Information
#
# Table name: cp_resources
#
#  id            :integer          not null, primary key
#  version       :integer
#  aasm_state    :string
#  publish_at    :datetime
#  list_urls     :json
#  small_package :string
#  large_package :string
#  memo          :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'rails_helper'

RSpec.describe CpResource, type: :model do
  let(:cp_resource) { create(:cp_resource) }

  describe '#aasm_state' do
    before(:each) { cp_resource.stub(:update_list_urls) }
    it 'starts with draft state' do
      expect(cp_resource).to be_draft
    end

    it 'transition from draft to published by publish' do
      expect { cp_resource.publish }.to change { cp_resource.aasm_state }.from('draft').to('published')
    end

    it 'transition from published to pulled by pull' do
      cp_resource.publish
      expect { cp_resource.pull }.to change { cp_resource.aasm_state }.from('published').to('pulled')
    end

    it 'transition from pulled to published by publish' do
      cp_resource.publish
      cp_resource.pull
      expect { cp_resource.publish }.to change { cp_resource.aasm_state }.from('pulled').to('published')
    end
  end
end
