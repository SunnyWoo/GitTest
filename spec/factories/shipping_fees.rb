# == Schema Information
#
# Table name: shipping_fees
#
#  id                    :integer          not null, primary key
#  type                  :string(255)
#  province_id           :integer
#  logistics_supplier_id :integer
#  country               :string(255)
#  currency              :string(255)
#  weight                :float
#  price                 :float
#  created_at            :datetime
#  updated_at            :datetime
#

FactoryGirl.define do
  factory :shipping_fee do
  end
end
