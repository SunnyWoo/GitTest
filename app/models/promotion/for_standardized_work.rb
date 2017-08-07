# == Schema Information
#
# Table name: promotions
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :text
#  type            :string(255)      not null
#  aasm_state      :integer
#  rule            :integer
#  rule_parameters :json
#  targets         :integer
#  begins_at       :datetime
#  ends_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  level           :integer
#

class Promotion::ForStandardizedWork < Promotion
  has_many :standardized_works, through: :promotion_references, source: :promotable, source_type: "StandardizedWork"

  def applicable?(item)
    standardized_works.include? item.itemable
  end

  def effecting_orders
    OrderQuery.new(Order.pending).by_standardized_works(standardized_works).execute
  end

  def order_level?
    false
  end

  def item_level?
    simple_discount? && (targets & ITEM_TARGET).present?
  end
end
