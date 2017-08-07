# == Schema Information
#
# Table name: campaign_images
#
#  id              :integer          not null, primary key
#  campaign_id     :integer
#  key             :string(255)
#  file            :string(255)
#  desc            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  link            :string(255)
#  open_in_new_tab :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe CampaignImage, type: :model do
  it { should allow_value('http://stackoverflow.com/').for(:link) }
  it { should_not allow_value('the return of jedi').for(:link) }
end
