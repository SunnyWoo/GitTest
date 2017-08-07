# == Schema Information
#
# Table name: packages
#
#  id                    :integer          not null, primary key
#  aasm_state            :string(255)
#  ship_code             :string(255)
#  shipped_at            :datetime
#  created_at            :datetime
#  updated_at            :datetime
#  package_no            :string(255)
#  logistics_supplier_id :integer
#

FactoryGirl.define do
  factory :package do
    aasm_state 'packaged'
    ship_code ''
    shipped_at ''
    shipping_info
  end
end
