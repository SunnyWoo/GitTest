# == Schema Information
#
# Table name: purchase_histories
#
#  id            :integer          not null, primary key
#  duration_id   :integer
#  product_id    :integer
#  category_name :string(255)
#  b2c_count     :integer
#  price         :float
#  price_tiers   :json
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :purchase_history, class: 'Purchase::History' do
  end
end
