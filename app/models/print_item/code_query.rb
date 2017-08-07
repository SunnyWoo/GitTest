class PrintItem::CodeQuery
  attr_reader :code

  # code可以为 print_item.code 或 print_item.timestamp_no
  def initialize(code)
    @code = code
  end

  def result
    PrintItem.ransack(timestamp_no_eq: timestamp_no).result
  end

  private

  def timestamp_no
    PrintItem::CodeHandler.decode(code)
  end
end
