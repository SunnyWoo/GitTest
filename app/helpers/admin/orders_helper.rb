module Admin::OrdersHelper
  def render_order_states_for_editable
    delete_state = %w(part_refunding part_refunded refunding refunded)
    Order.aasm.states_for_select.to_h.invert.delete_if { |key, _v| key.in?(delete_state) }
  end

  def delivery_from
    Region.china? ? t('order.show.deliver_taiwan') : t('order.show.deliver_shanghai')
  end

  def render_delivery_from(order_item)
    return t('order.show.deliver_local') unless order_item.delivered?
    return order_item.product_factory_name if order_item.external_production?
    delivery_from
  end

  def render_promotion_event_type_with_order(order, promotion)
    order.adjustments.where(source_type: promotion.class.name, source_id: promotion.id).order(created_at: :asc).last.try(:event) || '未套用'
  end

  def render_promotion_action(order, promotion)
    return if order.locked?
    return unless order.pending? && promotion.started?
    adjustments = order.adjustments.where(source_type: promotion.class.name, source_id: promotion.id)
    if adjustments.blank?
      link_to(t('shared.form_actions.manual'), manual_admin_promotion_path(promotion, order_uuid: order.uuid), class: 'btn btn-success', method: :put)
    elsif adjustments.pluck(:event).exclude? Adjustment.events['fallback']
      link_to(t('shared.form_actions.fallback'), fallback_admin_promotion_path(promotion, order_uuid: order.uuid), class: 'btn btn-danger', method: :delete)
    end
  end

  def render_adjustment_source_link(adjustment)
    case adjustment.source
    when Promotion
      link_to adjustment.source_name, edit_admin_promotion_path(adjustment.source)
    else
      link_to adjustment.source_name, url_for([:edit, :admin, adjustment.source])
    end
  end

  def link_to_create_adjustment(order)
    return if order.locked?
    link_to t('orders.adjustment_creation.button'), '#create_adjustment', data: { toggle: 'modal' }, class: 'btn no-border btn-primary'
  end

  def link_to_unlock_order_price(order)
    return unless order.locked?
    link_to t('orders.show.unlock'), admin_order_unlock_path(order), class: 'btn btn-danger', method: :patch
  end

  def render_promotion_name_link(promotion)
    link_to promotion.name, edit_admin_promotion_path(promotion)
  end
end
