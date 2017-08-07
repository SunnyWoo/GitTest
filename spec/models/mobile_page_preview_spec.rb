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

require 'rails_helper'

RSpec.describe MobilePagePreview, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
