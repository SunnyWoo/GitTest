class PrintItemDecorator < ApplicationDecorator
  delegate_all
  decorates_association :order_item
  decorates_association :order
  delegate :render_shipping_way, :render_shipping_way_with_color, to: :order

  def local_sublimated_at
    h.l(sublimated_at, format: :long) if sublimated_at
  end

  def timestamp_no
    if object.external_production?
      object.timestamp_no
    elsif object.order_item.delivered?
      '外部拋單'
    else
      object.timestamp_no
    end
  end

  def render_timestamp_no_with_highlight(target_timestamp_no = nil)
    span_class = (PrintItem::CodeHandler.decode(target_timestamp_no) == timestamp_no.to_s) ? 'highlight' : ''
    h.content_tag(:div, class: span_class) do
      h.render_timestamp_no(object)
    end
  end

  def after_sublimated_time
    h.render_hours_from_target_time(sublimated_at)
  end

  def product_by_other_factory?
    object.product.remote? || object.product.external_production? || object.order_item.delivered?
  end

  def shelving?
    object.received? || object.qualified?
  end

  def print_type_text
    last_history = object.print_histories.order(:created_at).last
    last_history.print_type_text if last_history
  end

  def order_no
    object.order.order_no
  end

  def render_days_from_created_at
    ((Time.zone.now - object.created_at) / 1.day).ceil
  end

  def link_to_workspace
    aasm_state = object.aasm_state
    number = object.timestamp_no.present? ? object.timestamp_no : object.order.order_no
    target_blank = { target: '_blank' }

    case aasm_state
    when 'pending', 'uploading'
      path = h.print_print_path(category_id: object.product.category_id, model_id: object.model_id, aasm_state: aasm_state)
      h.link_to '印刷站', path, target_blank
    when 'printed'
      path = h.print_sublimate_path(category_id: object.product.category_id, model_id: object.model_id)
      h.link_to '熱轉印站', path, target_blank
    when 'delivering', 'received', 'sublimated'
      h.link_to ' 質檢區', h.print_temp_shelves_path(timestamp_no: number), target_blank
    when 'qualified'
      h.link_to '包裝站', h.print_package_path(q: number), target_blank
    when 'onboard'
      h.link_to '出貨站', h.print_ship_path(q: number), target_blank
    else
      h.link_to '訂單搜尋', h.print_search_path(q: number), target_blank
    end
  end

  def render_aasm_state_in_schedule
    text = I18n.t("activerecord.attributes.print_item.aasm_state.#{object.aasm_state}")
    return text if object.aasm_state.in? %w(qualified onboard)
    h.content_tag :p, text, class: 'text-danger'
  end

  def link_to_disable_schedule
    h.link_to '隱藏', h.disable_schedule_print_print_item_path(object), remote: true, method: :patch, class: 'disable_schedule'
  end
end
