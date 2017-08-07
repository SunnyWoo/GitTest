class PackageDecorator < ApplicationDecorator
  delegate_all
  decorates_association :orders

  def render_shipping_ways_with_color
    object.orders.map do |order|
      h.content_tag(:p) do
        h.render_shipping_way_with_color(order.shipping_info.shipping_way)
      end
    end.join('').html_safe
  end

  def render_shipping_ways
    object.orders.map do |order|
      h.render_shipping_way(order.shipping_info.shipping_way)
    end.join("\n")
  end
end
