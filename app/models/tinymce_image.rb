# == Schema Information
#
# Table name: tinymce_images
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class TinymceImage < ActiveRecord::Base
  mount_uploader :file, DefaultUploader
end
