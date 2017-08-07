class PackageNoService
  def initialize(package)
    @package = package
    @time = package.created_at
  end

  def assign_package_no
    @package.update_attributes(package_no: "P#{package_no_date}#{random_code(2)}#{package_serial_number}#{random_code(1)}#{country_code}")
  end

  private

  def package_no_date
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

  def package_serial_number
    '%04d' % Package.where(created_at: @time.beginning_of_day..@time).count
  end

  def country_code
    @package.shipping_info_country_code
  end
end
