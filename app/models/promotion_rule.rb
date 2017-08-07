# == Schema Information
#
# Table name: promotion_rules
#
#  id                   :integer          not null, primary key
#  promotion_id         :integer
#  condition            :string(255)
#  threshold_id         :integer
#  product_model_ids    :integer          default([]), is an Array
#  designer_ids         :integer          default([]), is an Array
#  product_category_ids :integer          default([]), is an Array
#  work_gids            :text             default([]), is an Array
#  bdevent_id           :integer
#  quantity             :integer          default(1)
#  created_at           :datetime
#  updated_at           :datetime
#

class PromotionRule < ActiveRecord::Base
  include ActsAsFavorRule
end
