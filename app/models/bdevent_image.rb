# == Schema Information
#
# Table name: bdevent_images
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  locale     :string(255)
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class BdeventImage < ActiveRecord::Base
  belongs_to :bdevent
  mount_uploader :file, DefaultWithMetaUploader
end
