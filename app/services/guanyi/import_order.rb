class Guanyi::ImportOrder
  attr_accessor :import_order, :guanyi_trade, :user, :failed

  def initialize(import_order)
    @import_order = import_order
    @guanyi_trade = Guanyi::Trade.new
    @user = User.find_by!(email: 'guanyi@commandp.com')
    @failed = []
  end

  def generate_orders_by_file
    platform_codes_slices = platform_codes.each_slice(100).to_a
    platform_codes_slices.each_with_index do |platform_codes_slice, index|
      platform_codes_slice.each do |platform_code|
        build_order(platform_code)
      end
      sleep 60 if platform_codes_slices[index + 1]
    end
  end

  # 每执行100次休息一分钟
  def generate_order_by_failed
    failed_details_slices = import_order.failed.each_slice(100).to_a
    failed_details_slices.each_with_index do |failed_details_slice, index|
      failed_details_slice.each do |failed_detail|
        build_order(failed_detail.platform_code)
      end
      sleep 60 if failed_details_slices[index + 1]
    end
  end

  private

  def build_order(platform_code)
    guanyi_order = guanyi_trade.get_by_platform_code(platform_code)
    ActiveRecord::Base.transaction do
      order = Order.new(user: user)
      order.build_order(build_order_params(guanyi_order))
      order.save!
      order.pay!
      order.approve!
      import_order.succeeds.create!(order_id: order.id, guanyi_trade_code: guanyi_order.code, guanyi_platform_code: platform_code)
    end
  rescue ActiveRecord::RecordNotUnique
    failed << { platform_code: platform_code, message: 'OrderExistedError' }
  rescue ActiveRecord::RecordNotFound
    failed << { platform_code: platform_code, message: 'WorkNotFoundError' }
  rescue GuanyiNotFoundError
    failed << { platform_code: platform_code, message: 'GuanyiNotFoundError' }
  rescue GuanyiError
    failed << { platform_code: platform_code, message: 'GuanyiError' }
  rescue => e
    failed << { platform_code: platform_code, message: e }
  end

  def platform_codes
    CSV.parse(import_order.file.read)[1..-1].map { |csv| csv[3].delete("\t") }.uniq
  end

  def build_order_params(guanyi_order)
    {
      currency: 'CNY',
      payment: payment,
      billing_info: shipping_info(guanyi_order),
      shipping_info: shipping_info(guanyi_order),
      order_items: normalized_items(guanyi_order.details),
      message: 'create form TaoBao Or Tianmao'
    }
  end

  def payment
    # 正式启用后根据店铺名称选择支付方式
    'taobao_b2c'
  end

  def normalized_items(order_details)
    works = []
    order_details.each do |detail|
      work = find_work_by_product_code!(detail.item_code)
      works << { 'work_gid' => work.to_gid_param, 'quantity' => detail.qty.to_i } if work
    end
    works
  end

  def find_work_by_product_code!(product_code)
    WorkCode.find_by!(product_code: product_code).work
  end

  def shipping_info(guanyi_order)
    {
      address_name: 'TaoBao_TianMao',
      name: guanyi_order.receiver_name,
      email: user.email,
      address: guanyi_order.receiver_address,
      country: 'China',
      zip_code: guanyi_order.receiver_zip,
      country_code: 'CN',
      phone: guanyi_order.receiver_mobile || guanyi_order.phone,
      shipping_way: 0
    }
  end
end
