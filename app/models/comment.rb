# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  email      :string(255)
#  content    :text
#  is_admin   :boolean          default(FALSE)
#  created_at :datetime
#  updated_at :datetime
#

class Comment < ActiveRecord::Base
end
