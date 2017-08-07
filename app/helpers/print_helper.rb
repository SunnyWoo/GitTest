module PrintHelper
  def render_order_shipper(order)
    [].tap do |html|
      html << link_to(order.order_no, print_order_path(order), target: '_blank')
      html << content_tag(:span, I18n.t('order.payment.nuandao_b2b'), class: 'label label-success') if order.nuandao_b2b?
    end.reduce(:+)
  end

  def render_pending_count(factory)
    factory_model_ids = factory.product_models.pluck(:id)
    PrintItem.ransack(order_item_order_aasm_state_eq: 'paid',
                     aasm_state_eq: 'pending',
                     model_id_in: factory_model_ids).result.count
  end

  def render_printed_count(factory)
    factory_model_ids = factory.product_models.pluck(:id)
    PrintItem.ransack(order_item_order_aasm_state_eq: 'paid',
                     aasm_state_eq: 'printed',
                     model_id_in: factory_model_ids).result.count
  end

  def render_ready_package_count
    Order.paid.ransack(print_items_aasm_state_in: %w(qualified received)).result.size
  end

  def render_temp_shelf_count(_factory)
    Order.paid.ransack(print_items_aasm_state_in: %w(delivering sublimated)).result.size
  end

  def render_onboard_count
    Package.onboard.size
  end

  def render_shelves_count
    current_factory.shelves.sum(:quantity)
  end

  def render_materials_count
    current_factory.shelf_materials.sum(:quantity)
  end

  def render_picking_materials_count(model)
    model.picking_materials.sum(:quantity)
  end

  def link_to_add_mask_fields(name, partial, klass, f)
    new_object = klass.new
    fields = f.simple_fields_for :masks do |builder|
      render(partial, f: builder, mask: new_object)
    end
    link_to name, '#',
            class: 'btn btn-sm btn-success add_mask_fields',
            data: { id: new_object.object_id, fields: fields.delete("\n") }
  end

  def render_print_items_count(packages)
    packages.inject(0) { |sum, package| sum + package.print_items.size }
  end

  def render_order_items_quantity(orders)
    orders.inject(0) { |sum, order| sum + order.order_items.sum(:quantity) }
  end

  def render_shipping_way_with_color(shipping_way)
    info = render_shipping_way(shipping_way)
    if shipping_way == 'express'
      content_tag(:span, info, class: 'label label-yellow')
    else
      content_tag(:span, info, class: 'label label-grey')
    end
  end

  def render_shipping_way(shipping_way)
    I18n.t("shipping_info.shipping_way.#{Region.region}.#{shipping_way}")
  end

  def render_delayed_item_index(print_items, index)
    prev_pages_count = (print_items.current_page - 1) * print_items.per_page
    print_items.total_entries - prev_pages_count - index
  end

  # compare_times(单位: 秒) 取整，方便计算出相差的hours
  # 3666 / 3600 = 1
  def render_hours_from_target_time(time, target_time: Time.zone.now)
    return '' if time.blank?
    compare_times = (target_time - time).to_i
    hours = compare_times / 3600
    last_times = compare_times - hours * 3600
    minutes = last_times / 60
    seconds = last_times % 60
    "#{hours} : #{minutes} : #{seconds}"
  end

  def print_sidebar_link(*args, &block)
    if block_given?
      url, icon = args
      text = capture(&block)
    else
      text, url, icon = args
    end
    render 'print/shared/sidebar_link', text: text, url: url, icon: icon
  end

  def render_made_from(order_item)
    return t('delivery.made_from_factory', factory_name: order_item.product_factory_name) if order_item.external_production?
    Region.china? ? t('delivery.made_from_taiwan') : t('delivery.made_from_shanghai')
  end

  def render_timestamp_no(print_item, print_history = nil)
    timestamp_no = print_item.timestamp_no
    timestamp_no = print_history.timestamp_no if print_history.present?
    timestamp_no_info = [content_tag(:p, timestamp_no)]
    if print_item.product.enable_back_image?
      text = PrintItem::CodeHandler.encode(timestamp_no)
      timestamp_no_info << content_tag(:p, text)
    end
    safe_join(timestamp_no_info)
  end
end
