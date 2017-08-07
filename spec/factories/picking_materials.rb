# == Schema Information
#
# Table name: picking_materials
#
#  id         :integer          not null, primary key
#  model_id   :integer
#  material   :string(255)
#  quantity   :integer          default(1), not null
#  created_at :datetime
#  updated_at :datetime
#

FactoryGirl.define do
  factory :picking_material do
    product { create :product_model }
    material 'material'
    quantity 1
  end
end
