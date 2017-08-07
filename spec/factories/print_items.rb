# == Schema Information
#
# Table name: print_items
#
#  id              :integer          not null, primary key
#  order_item_id   :integer
#  timestamp_no    :integer
#  aasm_state      :string(255)
#  print_at        :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  model_id        :integer
#  prepare_at      :datetime
#  sublimated_at   :datetime
#  onboard_at      :datetime
#  package_id      :integer
#  qualified_at    :datetime
#  shipped_at      :datetime
#  enable_schedule :boolean          default(TRUE)
#

FactoryGirl.define do
  factory :print_item do
    order_item { create :order_item, order: create(:order) }
    product { create(:product_model) }

    trait :with_sublimated do
      aasm_state :sublimated
      order_item { create :order_item, :with_sublimated, order: create(:order) }
    end

    trait :with_qualified do
      aasm_state :qualified
      order_item { create :order_item, :with_qualified, order: create(:order) }
    end

    trait :with_onboard do
      aasm_state :onboard
      order_item { create :order_item, :with_onboard, order: create(:order) }
    end

    trait :with_archived_standardized_work_item do
      order_item { create :order_item, :with_standardized_work, order: create(:order) }
    end

    trait :with_delivering do
      aasm_state :delivering
      order_item { create :order_item, :with_delivering, order: create(:order) }
    end
  end
end
