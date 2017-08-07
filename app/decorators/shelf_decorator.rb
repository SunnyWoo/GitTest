class ShelfDecorator < Draper::Decorator
  decorates_association :material
  delegate :stock_warning?, to: :material, prefix: true, allow_nil: true

  delegate_all
end
