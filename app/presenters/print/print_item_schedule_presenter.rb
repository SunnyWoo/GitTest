class Print::PrintItemSchedulePresenter
  attr_reader :type, :options

  TYPE_OPTION = {
    urgent: 'Over 10 days',
    expedited: '7 - 10 days',
    normal: 'Under 7 days',
  }.freeze

  def initialize(options = {})
    @type = options[:type] || 'urgent'
    @options = options
  end

  def print_items
    @print_items ||= print_items_by_options.order('created_at asc').page(options[:page]).decorate
  end

  def print_items_count
    print_items.total_entries
  end

  def active_class(schedule_type)
    type == schedule_type.to_s ? 'active' : nil
  end

  private

  def print_items_by_options
    print_items = PrintItem.with_states(:pending, :uploading, :printed,
                                        :delivering, :received, :sublimated)
                           .where(enable_schedule: true)
    if options[:number].present?
      print_items.ransack(options_by_number).result
    else
      print_items.where(options_by_type)
    end
  end

  def options_by_number
    { timestamp_no_or_order_item_order_order_no_eq: options[:number] }
  end

  def options_by_type
    seven_days_from_now = Time.zone.now - 7.days
    ten_days_from_now = Time.zone.now - 10.days
    case type
    when 'normal'
      ['created_at > ?', seven_days_from_now]
    when 'expedited'
      ['created_at >= ? and created_at <= ?', ten_days_from_now, seven_days_from_now]
    when 'urgent'
      ['created_at < ?', ten_days_from_now]
    end
  end
end
