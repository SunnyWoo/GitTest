module Admin::ChangePriceEventsHelper
  def link_to_changeable(changeable)
    case changeable.class.name
    when 'ProductModel'
      link_to changeable.name, edit_admin_product_model_path(changeable), target: '_blank'
    when 'StandardizedWork'
      link_to changeable.name, [:admin, changeable], target: '_blank'
    end
  end

  def render_change_price_event_info(event)
    scope = 'change_price_events.index.thead'
    info = [[t('target_type', scope: scope), human_target_type(event.target_type)],
            [t('operator', scope: scope), event.operator.source_name],
            [t('created_at', scope: scope), l(event.created_at, format: :long)]]
    info.map { |i| i.join(': ') }
        .join('<br />')
        .html_safe
  end

  def human_target_type(target_type)
    I18n.t(target_type, scope: 'change_price_events.target_type')
  end
end
