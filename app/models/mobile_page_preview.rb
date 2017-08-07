# == Schema Information
#
# Table name: mobile_page_previews
#
#  id             :integer          not null, primary key
#  mobile_page_id :integer
#  key            :string
#  title          :string
#  country_code   :string
#  begin_at       :datetime
#  close_at       :datetime
#  page_type      :integer
#  contents       :json             default({})
#  is_enabled     :boolean
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class MobilePagePreview < ActiveRecord::Base
  belongs_to :mobile_page
  has_many :mobile_components, through: :mobile_page

  DEVICES = { iphone5s: '183x391',
              iphone6: '208x435',
              iphone6plus: '435x710',
              iphone6s: '208x435',
              iphone6splus: '435x710',
              nexus5: '200x398',
              nexus7: '364x634',
              nexus9: '433x644' }.freeze

  enum page_type: { homepage: 1, campaign_subject: 2, campaign_limited_time: 3, campaign_limited_quantity: 4 }
end
