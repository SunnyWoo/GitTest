# == Schema Information
#
# Table name: channel_codes
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ChannelCode < ActiveRecord::Base
  include UpcaseCode

  validates :code, uniqueness: true, presence: true, length: { is: 3 }
end
