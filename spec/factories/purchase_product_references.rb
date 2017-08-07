# == Schema Information
#
# Table name: purchase_product_references
#
#  id          :integer          not null, primary key
#  product_id  :integer
#  category_id :integer
#  b2c_count   :integer
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryGirl.define do
  factory :purchase_product_reference, class: 'Purchase::ProductReference' do
    product { create :product_model }
    category { create :purchase_category }
  end
end
