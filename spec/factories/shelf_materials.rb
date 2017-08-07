# == Schema Information
#
# Table name: shelf_materials
#
#  id                    :integer          not null, primary key
#  factory_id            :integer
#  name                  :string(255)
#  serial                :string(255)      not null
#  image                 :string(255)
#  quantity              :integer          default(0), not null
#  safe_minimum_quantity :integer          default(0)
#  scrapped_quantity     :integer          default(0)
#  aasm_state            :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  deleted_at            :datetime
#

FactoryGirl.define do
  factory :shelf_material do
    factory_id { create(:factory).id }
    sequence(:serial) { |n| "material#{n}" }
    name 'iPhone5包裝盒'
    quantity 10
  end
end
