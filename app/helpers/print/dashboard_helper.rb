module Print::DashboardHelper
  def render_print_item_preview(print_item)
    render_order_item_preview(print_item.order_item)
  end

  def render_order_item_image(order_item)
    item = order_item.itemable
    if pdf?(item.print_image)
      if item.order_image.present?
        item.order_image
      elsif item.is_a?(ArchivedWork)
        item.original_print_image
      end
    else
      item.print_image
    end
  end

  def render_order_item_preview(order_item)
    image = render_order_item_image(order_item)
    link_to image.url, class: 'fancybox' do
      image_tag image.thumb.url, width: 100
    end if image.present?
  end

  def render_order_item_image_with_base64(order_item)
    image = render_order_item_image(order_item)
    return nil unless image
    file = open(image.thumb.url).read
    Base64.encode64(file)
  end

  def render_sublimate_list(list, print_items, search)
    template = case list
               when 'normal' then 'sublimate_normal_list'
               when 'simple' then 'sublimate_simple_list'
               else fail "Unsupported list type: #{list}"
               end
    render template, print_items: print_items, search: search
  end

  def render_package_list(list, orders)
    template = case list
               when 'normal' then 'package_normal_list'
               when 'simple' then 'package_simple_list'
               else fail "Unsupported list type: #{list}"
               end
    render template, orders: orders
  end

  def render_ship_list(list, packages, logistics_suppliers)
    template = case list
               when 'normal' then 'ship_normal_list'
               when 'simple' then 'ship_simple_list'
               else fail "Unsupported list type: #{list}"
               end
    render template, packages: packages, logistics_suppliers: logistics_suppliers
  end

  def render_temp_shelf_list(list, orders, timestamp_no)
    template = case list
               when 'normal' then 'temp_shelf_normal_list'
               when 'simple' then 'temp_shelf_simple_list'
               else fail "Unsupported list type: #{list}"
               end
    render template, orders: orders, timestamp_no: timestamp_no
  end

  def render_order_history_list(list, orders)
    template = case list
               when :normal then 'order_history_normal_list'
               when :simple then 'order_history_simple_list'
               else fail "Unsupported list type: #{list}"
               end
    render template, orders: orders
  end

  def render_coupon_info(coupon)
    return '' if coupon.blank?
    coupon.title
  end

  def render_delivery_note_back_url(country_code)
    return '/download/delivery_note_back.pdf' if Region.china? || country_code == 'CN'
    locale = case country_code
             when 'TW', 'HK', 'MO'
               'zh-TW'
             when 'JP'
               'ja'
             else
               'en'
             end
    "/download/delivery_note_back_#{locale}.pdf"
  end

  def ship_company(order)
    if order.ship_code.to_s.start_with?('5')
      '圆通'
    elsif order.ship_code.to_s.start_with?('9')
      '顺丰'
    else
      ''
    end
  end

  def pdf?(image)
    image.file.try(:extension) == 'pdf' || image.path.to_s.end_with?('pdf')
  end

  def render_print_type_options
    PrintHistory::REPRINT_TYPE_OPTION.dup.delete_if { |key| key == :upload_fail_reprint }.to_a.map(&:reverse)
  end
end
