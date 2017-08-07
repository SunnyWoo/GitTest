class Pricing::SerialUnit
  attr_reader :item

  delegate :itemable, :selling_price, to: :item

  def initialize(item, serial_number)
    @serial_number = serial_number
    @item = item
  end

  def product
    item.itemable.product
  end

  def <=>(other)
    selling_price <=> other.selling_price
  end
end
