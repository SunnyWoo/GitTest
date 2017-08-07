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

class Adjustment < ActiveRecord::Base
  EVENT_TYPES = %w(apply fallback supply manual).freeze

  belongs_to :order, touch: true
  belongs_to :adjustable, polymorphic: true
  belongs_to :source, polymorphic: true

  enum event: EVENT_TYPES

  validates :event, :value, presence: true
  before_save :assign_order, unless: :order

  scope :discount, -> { where(event: events.slice('apply', 'supply').values) }
  scope :fallbackable, -> { where(event: events.slice('apply', 'supply', 'manual').values) }
  scope :order_level, -> { where(adjustable_type: 'Order').where.not(source_type: 'Promotion::ForShippingFee') }
  scope :item_level, -> { where(adjustable_type: 'OrderItem') }
  scope :by_promotion, -> { where('source_type LIKE ?', 'Promotion%') }

  delegate :source_name, to: :source
  delegate :adjustable_name, to: :adjustable

  def deferred?
    event.in?(%w(fallback supply manual))
  end

  def reason
    name = case source_type
           when /Promotion/
             'promotion'
           when /Admin/
             'admin'
           else
             'default'
           end
    I18n.t(event, scope: "adjustment.description.#{name}")
  end

  def revert!
    a = order.adjustments.find_or_initialize_by(revert_record_condition)
    a.value = value * -1
    a.save!
  end

  def reverted?
    return false if new_record?
    order.adjustments.find_by(revert_record_condition).present?
  end

  def fallback!
    return unless order.pending?

    if order.locked?
      order.order_locked_fallback_job_id =
        Promotion::OrderUnlockedEventWorker.perform_in(
          Order::PRICE_LOCKED_SESSION, id, order.id, 'fallback'
        )
      order.save
    else
      revert!
    end
  end

  def pricing?
    source.is_a?(Promotion) && source.item_level?
  end

  def discount?
    source.class.name.in? %w(Coupon)
  end

  def for_shipping_fee?
    source.class.name.in? %w(Promotion::ForShippingFee)
  end

  def order_level?
    adjustable.is_a?(Order) && !for_shipping_fee?
  end

  def item_level?
    adjustable.is_a?(OrderItem)
  end

  protected

  def revert_record_condition
    attributes.slice('adjustable_id',
                     'adjustable_type',
                     'source_id',
                     'source_type').merge('event' => Adjustment.events['fallback'])
  end

  def assign_order
    self.order ||= case adjustable
                   when Order
                     adjustable
                   when OrderItem
                     adjustable.order
                   end
  end
end
