# == Schema Information
#
# Table name: change_price_histories
#
#  id                     :integer          not null, primary key
#  change_price_event_id  :integer
#  changeable_id          :integer
#  changeable_type        :string(255)
#  price_type             :string(255)
#  original_price_tier_id :integer
#  target_price_tier_id   :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class ChangePriceHistory < ActiveRecord::Base
  belongs_to :change_price_event
  belongs_to :changeable, polymorphic: true
  belongs_to :original_price_tier, class_name: 'PriceTier', foreign_key: :original_price_tier_id
  belongs_to :target_price_tier, class_name: 'PriceTier', foreign_key: :target_price_tier_id
end
