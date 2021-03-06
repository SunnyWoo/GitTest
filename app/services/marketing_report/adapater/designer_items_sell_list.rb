require_dependency "#{Rails.root}/app/decorators/admin/marketing_report/order_item_decorator"

class MarketingReport::Adapater::DesignerItemsSellList
  def initialize(args = {})
    @starts_at, @ends_at = default_args_hash.merge(args.symbolize_keys).values_at(:starts_at, :ends_at).map do |value|
      value.is_a?(String) ? DateTime.parse(value).in_time_zone : value
    end
  end

  def send_data
    generate_csv_raw_data(target_items)
  end

  def decorator
    Admin::MarketingReport::OrderItemDecorator
  end

  private

  attr_reader :starts_at, :ends_at

  def today
    @today ||= DateTime.current
  end

  def default_args_hash
    { starts_at: today.beginning_of_month, ends_at: today }
  end

  def target_items
    OrderItem.between_times(starts_at, ends_at).joins(:order)
             .where(orders: { aasm_state: %w(paid shipping packaged part_refunded part_refunding) })
             .joins("
               left join standardized_works ON order_items.itemable_type = 'StandardizedWork' AND order_items.itemable_id = standardized_works.id
               left join archived_standardized_works ON order_items.itemable_type = 'ArchivedStandardizedWork' AND order_items.itemable_id = archived_standardized_works.id
               left join works ON order_items.itemable_type = 'Work' AND order_items.itemable_id = works.id
             ")
             .where("standardized_works.user_type = 'Designer' OR archived_standardized_works.user_type = 'Designer' OR works.user_type = 'Designer'" )
             .order(created_at: :asc)
  end

  def generate_csv_raw_data(target_items)
    CSV.generate do |csv|
      header = ['訂單ID',
                '訂單建立日期',
                '訂單付款日期',
                '平台',
                '產品型號',
                '設計師商品名稱',
                '設計師名稱',
                '使用貨幣',
                '原價',
                '特價',
                '特價優惠金額(原價-特價)',
                '優惠代碼',
                '銷售數量',
                '折扣',
                '銷售總計（數量＊金額）- 折扣']
      csv << header
      target_items.find_in_batches(batch_size: 500) do |batch_items|
        decorator.decorate_collection(batch_items).each do |item|
          data = [item.order_order_no,
                  item.order_created_at,
                  item.order_paid_at,
                  item.order_platform,
                  item.itemable_product_key,
                  item.itemable_name,
                  item.itemable_user_display_name,
                  item.order_currency,
                  item.original_price,
                  item.price,
                  item.special_price_profit,
                  item.order_embedded_coupon_code,
                  item.quantity,
                  item.discount.to_i,
                  item.actual_total_amount]
          csv << data
        end
      end
    end
  end
end
