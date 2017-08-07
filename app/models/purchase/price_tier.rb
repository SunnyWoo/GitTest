# == Schema Information
#
# Table name: purchase_price_tiers
#
#  id          :integer          not null, primary key
#  category_id :integer
#  count_key   :integer
#  price       :decimal(, )
#  created_at  :datetime
#  updated_at  :datetime
#

class Purchase::PriceTier < ActiveRecord::Base
  belongs_to :category, class_name: 'Purchase::Category'

  validates :count_key, presence: true
  validates :price, presence: true
end
