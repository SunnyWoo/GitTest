class NonStoreOrderError < ServiceObjectError
  def message
    '訂單不是來自於Store'
  end
end
