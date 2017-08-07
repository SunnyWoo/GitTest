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

class ChangePriceEvent < ActiveRecord::Base
  belongs_to :operator, class_name: 'Admin'
  belongs_to :price_tier
  has_many :change_price_histories
  validates :target_ids, :price_tier_id, :target_type, presence: true
  TARGET_TYPE = %w(StandardizedWorkPrice ProductPrice ProductCustomizedPrice).freeze
  validates :target_type, inclusion: { in: TARGET_TYPE }
  after_create :enqueue_change_price_worker

  include AASM
  aasm do
    state :pending, initial: true
    state :processing
    state :completed
    state :failed

    event :start do
      transitions from: [:pending, :failed], to: :processing
    end

    event :finish do
      transitions from: :processing, to: :completed
    end

    event :failure do
      transitions from: :processing, to: :failed
    end
  end

  def enqueue_change_price_worker
    ChangePriceWorker.perform_in(1.minute, id)
    start!
  end
end
