# == Schema Information
#
# Table name: promotions
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :text
#  type            :string(255)      not null
#  aasm_state      :integer
#  rule            :integer
#  rule_parameters :json
#  targets         :integer
#  begins_at       :datetime
#  ends_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  level           :integer
#

class Promotion < ActiveRecord::Base
  include Logcraft::Trackable
  include RedisCacheable
  include AASM
  include HasJobTracer
  include ActsAsAdjustmentSource
  include ActsAsAdjustmentBuilder

  AASM_STATES = %i(pending ready started ended stopped).freeze
  MUST_START_BEFORE = (Rails.env.production? ? 1.hour : 10.minutes).freeze
  LEVELS = %i(item_level order_level shipping_fee).freeze
  DISCOUNT_TYPES = %w(fixed percentage pay).freeze

  has_many :adjustments, as: :source

  value :beginning_job_id
  value :ending_job_id

  enum aasm_state: AASM_STATES
  enum level: LEVELS

  serialize :rule_parameters, Hashie::Mash.pg_json_serializer

  validates :name, :type, presence: true
  validate :validate_no_same_products

  scope :available, -> (time = Time.zone.now) { started.where('begins_at < :time AND (ends_at > :time OR ends_at is NULL)', time: time) }
  scope :for_itemable_price, -> { where(type: 'Promotion::ForItemablePrice') }

  after_destroy :purge_enqueued_jobs

  aasm enum: true do
    state :pending, initial: true
    state :ready
    state :started
    state :ended
    state :stopped

    event :submit do
      transitions from: :pending, to: :ready
      after do
        enqueue_beginning_job
      end
    end

    event :start do
      transitions from: :ready, to: :started
      after do
        note_event('started')
        enqueue_supply_job
        enqueue_ending_job if ends_at
        flush_promotable_caches if item_level?
      end
    end

    event :complete do
      transitions from: :started, to: :ended
      after do
        note_event('completed')
        purge_enqueued_jobs
        enqueue_fallback_job
        flush_promotable_caches if item_level?
      end
    end

    event :stop do
      transitions from: [:ready, :started], to: :stopped
      after do
        note_event('stopped')
        flush_promotable_caches
        purge_enqueued_jobs
      end
    end
  end

  def effecting_orders;    raise NoMethodError.new('subclass responsibility'); end

  def applicable?(*_args); raise NoMethodError.new('subclass responsibility'); end

  def apply;               raise NoMethodError.new('subclass responsibility'); end

  def supply;              raise NoMethodError.new('subclass responsibility'); end

  def manual;              raise NoMethodError.new('subclass responsibility'); end

  def conditioned?;        raise NoMethodError.new('subclass responsibility'); end

  def fallback(order)
    return unless order.pending?
    order.adjustments.discount.where(source: promotion).find_each(&:fallback!)
    order.calculate_price!
  end

  def fallback!
    adjustments.discount.joins(:order).
      where('orders.aasm_state' => 'pending').
      group_by(&:order).each do |order, adjs|
        adjs.each(&:fallback!)
        order.calculate_price!
      end
  end

  def supply!
    effecting_orders.each do |order|
      if order.locked?
        order.order_locked_supply_job_id =
          Promotion::OrderUnlockedEventWorker.perform_in(
            Order::PRICE_LOCKED_SESSION, id, order.id, 'supply'
          )
        order.save
      else
        supply(order)
      end
    end
  end

  def rule_price_tier=(price_tier_id)
    rule_parameters['price_tier_id'] = price_tier_id
  end

  def rule_price_tier
    rule_parameters['price_tier_id']
  end

  def rule_percentage=(percentage)
    return unless percentage.present?
    rule_parameters['percentage'] = percentage.to_f < 1 ? percentage : percentage.to_f / 100
  end

  def rule_percentage
    rule_parameters['percentage']
  end

  def rule_discount_type=(discount_type)
    rule_parameters['discount_type'] = discount_type
  end

  def rule_discount_type
    rule_parameters['discount_type']
  end

  def price_tier
    @price_tier ||= PriceTier.find_by(id: rule_price_tier)
  end

  def price_in_currency(currency)
    price_tier.prices[currency]
  end

  def rule_threshold_price_tier=(price_tier_id)
    rule_parameters['threshold_price_tier_id'] = price_tier_id
  end

  def rule_threshold_price_tier
    rule_parameters['threshold_price_tier_id']
  end

  def threshold_price_tier
    @threshold_price_tier ||= PriceTier.find_by(id: rule_threshold_price_tier)
  end

  def threshold_price_in_currency(currency)
    threshold_price_tier.prices[currency]
  end

  def can_delete?
    aasm_state.in? %w(pending ready)
  end

  def can_update?
    aasm_state.in? %w(pending)
  end

  def can_submit?
    pending? && valid?
  end

  def unified_discount?
    self.class.ancestors.any? { |o| o == ActsAsUnifiedDiscountPromotion }
  end

  def fallback_the_order(order)
    return unless order.pending?
    adjustments.fallbackable.includes(:order).where(order: order).find_each(&:fallback!)
  end

  def manual_the_order(order)
    return unless order.pending?
    manual(order)
  end

  def source_name
    "#{self.class.name}: #{name}"
  end

  def order_eligible?(order)
    if order_level? || shipping_fee?
      applicable?(order)
    else
      order.order_items.any? { |item| applicable?(item) }
    end
  end

  protected

  def flush_promotable_caches
    pids = []
    pids += product_ids if respond_to?(:products)
    pids += ProductModel.where(category_id: product_category_ids).pluck(:id) if respond_to?(:product_categories)

    # product model
    ProductModel.where(id: pids).find_each(&:flush_cached_promotion_prices)

    # work/standardized work
    standardized_works.find_each(&:flush_cached_promotion_prices) if respond_to?(:standardized_works)
    Work.where(model_id: pids).find_each(&:flush_cached_promotion_prices)
    StandardizedWork.where(model_id: pids).find_each(&:flush_cached_promotion_prices)
  end

  def enqueue_supply_job
    Promotion::AdjustmentSupplyWorker.perform_async(id)
  end

  def enqueue_fallback_job
    return unless ends_at
    Promotion::AdjustmentFallbackWorker.perform_async(id)
  end

  def enqueue_beginning_job
    self.beginning_job_id = Promotion::SchedulingWorker.perform_at(begins_at, id, 'start')
  end

  def enqueue_ending_job
    self.ending_job_id = Promotion::SchedulingWorker.perform_at(ends_at, id, 'complete')
  end

  def purge_enqueued_jobs
    %w(beginning ending).each do |key|
      job_id = send("#{key}_job_id").value
      next unless job_id

      if kill_background_job(job_id)
        create_activity("cancel_#{key}_job", job_id: job_id) unless destroyed?
        send("#{key}_job_id=", nil)
      else
        create_activity("#{key}_job_missing", job_id: job_id) unless destroyed?
      end
    end
  end

  def note_event(status)
    create_activity("had_#{status}")
  end

  def validate_no_same_products
    return unless ready? || started?
    return unless self.class.name.in?(%w(Promotion::ForProductModel Promotion::ForProductCategory Promotion::ForItemablePrice))
    return if references.empty?
    same_product_ids = related_product_ids & overlapped_product_ids
    if same_product_ids.count > 0
      names = ProductModel.where(id: same_product_ids).map(&:name).join(', ')
      errors.add(:rules, I18n.t('errors.same_products_in_promotions', names: names))
    end
  end

  def related_product_ids(refs = references)
    reference_product_ids = refs.where(promotable_type: 'ProductModel').pluck(:promotable_id)
    reference_category_ids = refs.where(promotable_type: 'ProductCategory').pluck(:promotable_id)
    (reference_product_ids + ProductModel.available.where(category_id: reference_category_ids).pluck(:id)).uniq
  end

  def overlapped_product_ids
    refs = PromotionReference.where(promotion_id: overlapped_promotions.map(&:id))
    related_product_ids(refs)
  end

  def overlapped_promotions
    overlapped_condition = if ends_at.blank?
                             'ends_at is NULL OR ends_at >= :begins_at'
                           else
                             '(ends_at is NULL AND begins_at <= :ends_at)' \
                             ' OR (ends_at <= :ends_at AND ends_at >= :begins_at)' \
                             ' OR (begins_at <= :ends_at AND begins_at >= :begins_at)' \
                             ' OR (begins_at <= :begins_at AND ends_at >= :ends_at)'
                           end
    states = [Promotion.aasm_states[:ready], Promotion.aasm_states[:started]]
    Promotion.where(aasm_state: states)
             .where(overlapped_condition, begins_at: begins_at, ends_at: ends_at).reject { |p| p == self }
  end
end
