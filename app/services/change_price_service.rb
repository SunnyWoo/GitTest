class ChangePriceService
  TARGET_TYPE_MAPPING = {
    'standardized_work_price' => [StandardizedWork, 'price_tier_id'],
    'product_price' => [ProductModel, 'price_tier_id'],
    'product_customized_price' => [ProductModel, 'customized_special_price_tier_id']
  }.freeze

  def initialize(event_id)
    @event_id = event_id
  end

  def event
    @event ||= ChangePriceEvent.find(@event_id)
  end

  def execute
    changeable_class, price_type = TARGET_TYPE_MAPPING.fetch(event.target_type.underscore)
    ActiveRecord::Base.transaction do
      changeable_class.where(id: target_ids).find_each do |changeable|
        original_price_tier_id = changeable.send(price_type)
        changeable.assign_attributes(price_type.to_sym => target_price_tier_id)
        changeable.change_price_histories.new(original_price_tier_id: original_price_tier_id,
                                              target_price_tier_id: target_price_tier_id,
                                              price_type: price_type,
                                              change_price_event: event)
        changeable.save!
        changeable.flush_cached_promotion_prices if changeable.is_a?(ProductModel)
      end
    end
  end

  private

  def target_ids
    event.target_ids
  end

  def target_price_tier_id
    event.price_tier_id
  end
end
