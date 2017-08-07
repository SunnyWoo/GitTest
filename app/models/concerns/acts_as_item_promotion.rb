module ActsAsItemPromotion
  extend ActiveSupport::Concern

  included do
    after_initialize :set_default_values
  end

  def fetch_promotion_price(_promotable)
    raise NotImplementedError, 'subclass responsibility'
  end

  def build_apply_adjustment(order_item)
    value = calculate_adjustment_value(order_item)
    build_adjustment(order_item.order, order_item, self, 'apply', value, order_item.quantity) unless value.zero?
  end

  %w(apply supply manual).each do |event|
    define_method(event) do |order|
      extract_items(order) do |order_item|
        value = calculate_adjustment_value(order_item)
        find_or_create_adjustments(order, order_item, self, event, value, order_item.quantity) unless value.zero?
      end
    end
  end

  def applicable?(item)
    item.itemable.current_promotion == self
  end

  def extract_items(order)
    items = order.order_items.select { |item| applicable?(item) }

    if block_given?
      items.each { |item| yield(item) }
    else
      items
    end
  end

  private

  def calculate_adjustment_value(order_item)
    quantity = order_item.quantity
    target_currency = order_item.order.currency
    order_item.itemable.promotion_discount_price.fetch(target_currency).to_f * quantity * -1
  end

  def set_default_values
    self.level = "item_level"
  end
end
