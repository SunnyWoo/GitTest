# == Schema Information
#
# Table name: purchase_categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Purchase::Category < ActiveRecord::Base
  has_many :price_tiers, class_name: 'Purchase::PriceTier', dependent: :destroy
  has_many :product_references, class_name: 'Purchase::ProductReference'
  has_many :products, through: :product_references
  accepts_nested_attributes_for :price_tiers, allow_destroy: true

  validates :name, presence: true

  def purchase_price
    b2c_total_count = product_references.sum(:b2c_count)
    count_keys = price_tiers.pluck(:count_key).sort { |x, y| y <=> x }
    count_key = count_keys.find { |key| key <= b2c_total_count }

    price_tiers.find_by(count_key: count_key).price
  end

  def simplify_price_tiers
    price_tiers.map{ |price_tier| { count_key: price_tier.count_key, price: price_tier.price } }
  end
end
