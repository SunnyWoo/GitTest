class Admin::ChangePriceEventForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_reader :change_price_event, :q

  delegate :target_ids, :price_tier_id, :target_type, to: :change_price_event

  validates :target_ids, :price_tier_id, :target_type, presence: true

  def initialize(change_price_event, q: {})
    @change_price_event = change_price_event
    @q = q || {}
  end

  def assign_attributes(attrs)
    change_price_event.attributes = attrs
  end

  alias_method :attributes=, :assign_attributes

  def save
    valid? && change_price_event.save
  end

  def target_type
    @target_type ||= ChangePriceEvent::TARGET_TYPE.first
  end

  def target_type_options
    ChangePriceEvent::TARGET_TYPE.map do |type|
      [I18n.t(type, scope: 'change_price_events.target_type'), type]
    end
  end

  def search
    StandardizedWork.is_public.ransack(@q)
  end

  def works
    @q.values.any?(&:present?) ? search.result : []
  end

  def product_models
    @product_models ||= ProductModel.available
  end

  def categories
    @categories ||= ProductCategory.available
  end
end
