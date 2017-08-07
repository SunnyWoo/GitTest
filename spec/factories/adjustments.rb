# == Schema Information
#
# Table name: adjustments
#
#  id              :integer          not null, primary key
#  order_id        :integer
#  adjustable_id   :integer
#  adjustable_type :string(255)
#  source_id       :integer
#  source_type     :string(255)
#  value           :float            not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  target          :integer
#  event           :integer          not null
#  quantity        :integer          default(1), not null
#

FactoryGirl.define do
  factory :adjustment do
    order { create :order, :with_public_work }
    # target Adjustment.targets.fetch('special')
    event 'apply'
    value(-50)
    source { create :standardized_work_promotion }
    after :build do |adjustment|
      if adjustment.adjustable.nil?
        adjustment.adjustable = adjustment.order.order_items.first
      end
    end

    trait :apply do
      event 'apply'
    end

    trait :fallback do
      event 'fallback'
    end

    trait :supply do
      event 'supply'
    end

    trait :manual do
      event 'manual'
    end
  end
end
