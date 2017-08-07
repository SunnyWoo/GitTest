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

require 'rails_helper'

RSpec.describe Purchase::History, type: :model do
  context '#association' do
    it { should belong_to(:duration) }
  end

  context '.create_histories' do
    Given(:category) { create :purchase_category, name: 'mugs' }
    Given!(:product_tier_1) { create :purchase_price_tier, category: category, count_key: 0, price: 100 }
    Given!(:product_tier_2) { create :purchase_price_tier, category: category, count_key: 100, price: 50 }
    Given!(:product_reference_1) { create :purchase_product_reference, category: category, b2c_count: 10, product_id: 1 }
    Given!(:product_reference_2) { create :purchase_product_reference, category: category, b2c_count: 10, product_id: 2 }

    When { Purchase::History.create_histories }
    Given(:history) { Purchase::History.last }
    Then { Purchase::History.all.size == 2 }
    And { history.price == category.purchase_price }
    And { history.price_tiers.as_json == [{ 'count_key' => 0, 'price' => '100.0' }, { 'count_key' => 100, 'price' => '50.0' }] }
  end
end
