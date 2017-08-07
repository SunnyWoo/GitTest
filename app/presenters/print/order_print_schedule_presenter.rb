class Print::OrderPrintSchedulePresenter
  attr_reader :type, :options

  TYPE_OPTION = {
    urgent: 'Over 15 days',
    expedited: '10 - 15 days',
    normal: 'Under 10 days',
  }.freeze

  def initialize(options = {})
    @type = options[:type] || 'urgent'
    @options = options
  end

  def orders
    @orders ||= orders_by_options.order('orders.approved_at asc').page(options[:page]).decorate
  end

  def orders_count
    orders.total_entries
  end

  def active_class(schedule_type)
    type == schedule_type.to_s ? 'active' : nil
  end

  private

  def orders_by_options
    orders = Order.includes(:print_items)
                  .with_states(:paid, :packaged, :part_refunded, :part_refunding)
                  .where(enable_schedule: true)
    if options[:number].present?
      orders.ransack(options_by_number).result
    else
      orders.where(options_by_type)
    end
  end

  def options_by_number
    { print_items_timestamp_no_or_order_no_eq: options[:number] }
  end

  def options_by_type
    ten_days_from_now = Time.zone.now - 10.days
    fifteen_days_from_now = Time.zone.now - 15.days
    case type
    when 'normal'
      ['approved_at > ?', ten_days_from_now]
    when 'expedited'
      ['approved_at >= ? and approved_at <= ?', fifteen_days_from_now, ten_days_from_now]
    when 'urgent'
      ['approved_at < ?', fifteen_days_from_now]
    end
  end
end
