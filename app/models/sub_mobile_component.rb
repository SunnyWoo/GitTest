# == Schema Information
#
# Table name: mobile_components
#
#  id             :integer          not null, primary key
#  mobile_page_id :integer
#  key            :string(255)
#  parent_id      :integer
#  position       :integer
#  image          :string(255)
#  contents       :json
#  created_at     :datetime
#  updated_at     :datetime
#

class SubMobileComponent < MobileComponent
  acts_as_list scope: [:parent_id, :key]
  default_scope { order('position ASC') }

  belongs_to :mobile_component, class_name: 'MobileComponent', foreign_key: 'parent_id', touch: true
  mount_uploader :image, DefaultWithMetaUploader
end
