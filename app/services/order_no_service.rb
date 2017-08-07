require 'carmen'
include Carmen

class OrderNoService
  def initialize(order)
    @order = order
    @time = order.created_at
  end

  def assign_order_no
    @order.update_attributes(order_no: "#{order_no_date}#{random_code(2)}#{order_serial_number}#{random_code(1)}#{country_code}")
  end

  private

  def order_no_date
    "#{last_two_digits_of_created_year}#{created_month_and_day}"
  end

  def created_month_and_day
    @time.strftime('%m%d')
  end

  def last_two_digits_of_created_year
    @time.strftime('%Y')[2, 2]
  end

  def random_code(digit)
    return if digit < 1
    code = ''
    digit.times do
      code += rand(1..9).to_s
    end
    code
  end

  def order_serial_number
    '%04d' % Order.where(created_at: @time.beginning_of_day..@time).count
  end

  def country_code
    @order.billing_info_country_code
  end
end
