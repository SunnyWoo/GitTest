# == Schema Information
#
# Table name: delivery_orders
#
#  id             :integer          not null, primary key
#  model_id       :integer
#  order_no       :string(255)
#  print_item_ids :integer          default([]), not null, is an Array
#  state          :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delivery_order do
    order_no 'MyString'
    print_item_ids []
    product { create :product_model }
  end
end
