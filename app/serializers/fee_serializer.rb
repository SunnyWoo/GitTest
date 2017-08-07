# == Schema Information
#
# Table name: fees
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#

# NOTE: not used in v3 api, remove me later
class FeeSerializer < ActiveModel::Serializer
  attributes :name
  has_many :currencies
end
