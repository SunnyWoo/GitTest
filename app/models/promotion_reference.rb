# == Schema Information
#
# Table name: promotion_references
#
#  id              :integer          not null, primary key
#  promotion_id    :integer
#  promotable_id   :integer
#  promotable_type :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  price_tier_id   :integer
#

class PromotionReference < ActiveRecord::Base
  belongs_to :promotion
  belongs_to :promotable, polymorphic: true
  belongs_to :price_tier
end
