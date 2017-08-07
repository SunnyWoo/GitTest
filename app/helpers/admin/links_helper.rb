module Admin::LinksHelper
  def link_to_admin_order(order)
    link_to order.order_no, admin_order_path(order)
  end

  def link_to_admin_work(work, options = {})
    if options[:deleted].to_b
      link_to work.name, admin_work_path(work, deleted: true)
    else
      link_to work.name, admin_work_path(work)
    end
  end

  def link_to_pingpp_alipay_refund(src)
    return if src.nil?
    link_to '退款', 'https:' + src.split('https:').last, target: 'blank'
  end
end
