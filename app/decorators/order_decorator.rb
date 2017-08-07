class OrderDecorator < ApplicationDecorator
  delegate_all
  decorates_association :order_items
  decorates_association :print_items
  delegate :message, to: :object

  def print_items_completed_count
    object.print_items.pluck(:aasm_state).count { |state| %w(received onboard qualified shipping).include?(state) }
  end

  def order_items_count
    object.order_items.size
  end

  def print_items_count
    object.print_items.size
  end

  def allow_package?
    print_items_count == print_items_completed_count
  end

  def forbid_package?
    !allow_package?
  end

  def package_button_state
    forbid_package? ? 'disabled' : ''
  end

  def progress_rate
    h.calculate_percentage(print_items_completed_count, print_items_count)
  end

  def prepare_to_merge?
    can_be_packaged_all? && merge_target_ids.present?
  end

  def render_merge_notice
    merge_target_ids.present? ? 'Yes' : 'No'
  end

  def render_progress_bar
    h.content_tag(:div, class: 'progress progress-striped active', data: { percent: "#{progress_rate}%" }) do
      h.content_tag(:div, '', class: 'progress-bar', style: "width: #{progress_rate}%")
    end
  end

  def shipping_state
    I18n.t("activerecord.attributes.order.shipping_state.#{order.shipping_state}")
  end

  def packaging_state
    I18n.t("activerecord.attributes.order.packaging_state.#{order.packaging_state}")
  end

  def render_remote_notice
    (object.remote_id.present? && !object.external_production?) ? 'Yes' : 'No'
  end

  def render_external_production_notice
    object.external_production? ? 'Yes' : 'No'
  end

  def render_days_from_approved_at
    ((Time.zone.now - object.approved_at) / 1.day).ceil
  end

  def discount
    object.discount + object.shipping_fee_discount
  end

  def render_shipping_way_with_color
    h.render_shipping_way_with_color(object.shipping_info_shipping_way)
  end

  def link_to_disable_schedule
    h.link_to '隱藏', h.disable_schedule_print_order_path(object), remote: true, method: :patch, class: 'disable_schedule'
  end
end
