# == Schema Information
#
# Table name: shelves
#
#  id                    :integer          not null, primary key
#  serial                :string(255)
#  section               :string(255)
#  name                  :string(255)
#  quantity              :integer          default(0)
#  factory_id            :integer
#  created_at            :datetime
#  updated_at            :datetime
#  serial_name           :string(255)
#  safe_minimum_quantity :integer          default(0)
#  material_id           :integer
#  category_id           :integer
#  deleted_at            :datetime
#

FactoryGirl.define do
  factory :shelf do
    sequence(:serial) { |n| "CDC101231#{n}" }
    sequence(:section) { |n| "12345000#{n}" }
    name 'iPhone5包裝盒'
    quantity 1
    category { create :shelf_category }
    material { create :shelf_material }
    factory_id { (create :factory).id }
  end
end
