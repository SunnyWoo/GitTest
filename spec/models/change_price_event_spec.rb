# == Schema Information
#
# Table name: change_price_events
#
#  id            :integer          not null, primary key
#  operator_id   :integer
#  target_ids    :integer          default([]), is an Array
#  price_tier_id :integer
#  target_type   :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  aasm_state    :string(255)
#

require 'rails_helper'

RSpec.describe ChangePriceEvent, type: :model do
  it { should validate_presence_of(:target_ids) }
  it { should validate_presence_of(:price_tier_id) }
  it { should validate_presence_of(:target_type) }

  context 'aasm state' do
    context 'event completed' do
      Given!(:change_price_event) { create :change_price_event, :with_product_price, target_ids: [1] }
      Then { ChangePriceWorker.jobs.size == 1 }
      And { change_price_event.reload.aasm_state == 'processing' }
      And { change_price_event.finish! }
      And { change_price_event.reload.aasm_state == 'completed' }
    end

    context 'event failed' do
      Given!(:change_price_event) { create :change_price_event, :with_product_price, target_ids: [1] }
      Then { ChangePriceWorker.jobs.size == 1 }
      And { change_price_event.aasm_state == 'processing' }
      And { change_price_event.failure! }
      And { change_price_event.reload.aasm_state == 'failed' }
      And { change_price_event.start! }
      And { change_price_event.reload.aasm_state == 'processing' }
    end
  end
end
