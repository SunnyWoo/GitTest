# == Schema Information
#
# Table name: provinces
#
#  id         :integer          not null, primary key
#  area_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  code       :string(2)
#

class Province < ActiveRecord::Base
  has_many :shipping_fees
  has_many :shipping_infos
  belongs_to :area

  validates :name, presence: true, uniqueness: true

  SPECIAL_NAME = '江苏省（宿迁、连云港、徐州）'.freeze

  scope :normal, -> { where.not(name: SPECIAL_NAME) }
end
