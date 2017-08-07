class ShelfMaterialDecorator < Draper::Decorator
  delegate_all

  def stock_warning?
    quantity < safe_minimum_quantity
  end
end
