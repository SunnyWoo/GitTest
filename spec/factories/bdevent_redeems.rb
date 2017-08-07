# == Schema Information
#
# Table name: bdevent_redeems
#
#  id                :integer          not null, primary key
#  code              :string(255)
#  bdevent_id        :integer
#  parent_id         :integer
#  children_count    :integer          default(0)
#  usage_count       :integer          default(0)
#  usage_count_limit :integer          default(-1)
#  product_model_ids :integer          default([]), is an Array
#  order_ids         :integer          default([]), is an Array
#  is_enabled        :boolean          default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#  work_ids          :integer          default([]), is an Array
#

FactoryGirl.define do
  factory :bdevent_redeem do
    bdevent { create(:bdevent) }
    usage_count_limit 1
    factory :used_bdevent_redeem do
      order_ids { [create(:order).id] }
    end
  end
end
