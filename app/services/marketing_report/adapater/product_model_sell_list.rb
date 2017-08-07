class MarketingReport::Adapater::ProductModelSellList
  def initialize(args = {})
    @month, @year = default_args_hash.merge(args.symbolize_keys).values_at(:month, :year)
  end

  def send_data
    generate_csv_raw_data(normalize_items_data(target_items))
  end

  private

  attr_reader :month, :year

  def days_in_month
    1..Time.days_in_month(month.to_i, year.to_i)
  end

  def default_args_hash
    { month: today.month, year: today.year }
  end

  def today
    @today ||= DateTime.current
  end

  def target_items
    @target_items or begin
      orders_ids = Order.by_month(month).user_was_paid.pluck(:id)
      @target_items = OrderItem.where(order_id: orders_ids).select("*, to_char(created_at, 'dd') as day")
    end
  end

  def target_model_names
    @target_model_names or begin
      items_model = target_items.includes(itemable: :product).map { |oi| oi.itemable.product }.uniq
      @target_model_names = (ProductModel.available + items_model).uniq.map(&:name)
    end
  end

  # 很醜，但目前也只能這樣....
  def normalize_items_data(order_items)
    days_in_month.each_with_object({}) do |day, result_data|
      formatted_day = '%02d' % day
      result_data[formatted_day] = {}
      day_order_items = order_items.select { |item| item.day == formatted_day }
      order_items -= day_order_items
      target_model_names.each do |model_name|
        result_data[formatted_day][model_name] = { count: 0, amount: 0 }
        day_order_items.each do |item|
          next unless item.itemable.product_name == model_name
          result_data[formatted_day][model_name][:count] += item.quantity
          currency = item.order.currency
          amount = (item.quantity * item.price_in_currency(currency)) - item.discount.to_i
          if currency != 'TWD'
            price_calculator = PriceCalculator.new(item.order, currency)
            amount = price_calculator.send :to_target_currency, amount, 'TWD'
            amount = price_calculator.send :floored_value, amount, currency
          end
          result_data[formatted_day][model_name][:amount] += amount
        end
      end
    end
  end

  def generate_csv_raw_data(result_data)
    CSV.generate do |csv|
      csv << target_model_names.map { |model_name| [model_name, ' '] }.flatten.unshift('Date') # header
      csv << target_model_names.map { |_| %w(Count Amount) }.flatten.unshift(' ')
      result_data.each do |day_data|
        row_data = []
        row_data << day_data.first
        day_data.last.each do |_model_name, data_hash|
          row_data << data_hash[:count]
          row_data << data_hash[:amount]
        end
        csv << row_data
      end
    end
  end
end
