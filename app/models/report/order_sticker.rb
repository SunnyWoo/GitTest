# == Schema Information
#
# Table name: daily_records
#
#  id         :integer          not null, primary key
#  type       :string
#  data       :json
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  target_ids :integer          default([]), is an Array
#

class Report::OrderSticker < DailyRecord
  default_scope { order('created_at asc') }

  serialize :data, Report::OrderSticker::DataInfo
  validate :validate_create_once_for_a_day, on: :create

  def orders(reload = false)
    if reload
      @orders = Order.where(id: target_ids)
    else
      @orders ||= Order.where(id: target_ids)
    end
  end

  def sold_customized_order_items_count
    orders.map(&:order_items).flatten.reduce(0) do |count, item|
      [Work, ArchivedWork].include?(item.itemable.class) ? count + item.quantity  : count
    end.to_i
  end

  def sold_designer_order_items_count
    orders.map(&:order_items).flatten.reduce(0) do |count, item|
      [Work, ArchivedWork].exclude?(item.itemable.class) ? count + item.quantity  : count
    end.to_i
  end

  # 客製化商品中使用有sticker_type的layers數 乘以 訂單商品數量；用來當做sticker_type使用數量比例的分母
  def sold_customized_order_items_layers_count(product_keys = 'all')
    orders.map(&:order_items).flatten.reduce(0) do |count, item|
      if [Work, ArchivedWork].include?(item.itemable.class) && product_keys.in?([:all, 'all'])
        count + (item.itemable.layers.where(layer_type: Layer::STICKER_TYPES).size * item.quantity)
      elsif [Work, ArchivedWork].include?(item.itemable.class) && product_keys.include?(item.itemable.product.key)
        count + (item.itemable.layers.where(layer_type: Layer::STICKER_TYPES).size * item.quantity)
      else
        count
      end
    end.to_i
  end

  private

  def validate_create_once_for_a_day
    return if Report::OrderSticker.count == 0
    return unless Report::OrderSticker.last.created_at.day == DateTime.current.day
    errors.add(:base, '為確保統計報表的資料間斷性，一天僅建立一筆記錄')
  end
end
