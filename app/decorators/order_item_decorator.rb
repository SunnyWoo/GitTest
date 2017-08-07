class OrderItemDecorator < ApplicationDecorator
  delegate_all
  decorates_association :print_items

  def unpackaged_print_items
    object.print_items.unpackaged.decorate
  end
end
