class ProductModelPolicy < PrintPolicy
  # 揀貨對應
  permit %i(pick)
end
