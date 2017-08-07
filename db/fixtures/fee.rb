require 'seed-fu'

fee_seeds = %w(運費 express cash_on_delivery).map { |s| { name: s } }
Fee.seed(:name, fee_seeds)

fee = Fee.find_by(name: '運費')

{ HKD: 50.0, JPY: 750.0, TWD: 210.0, USD: 6.99 }.each do |code, price|
  currency_type = CurrencyType.find_by(code: code)
  next unless currency_type
  row = {
    payable_type: 'Fee',
    payable_id: fee.id,
    name: currency_type.name,
    code: currency_type.code,
    price: price
  }
  Currency.seed_once(:name, :code, :payable_type, :payable_id, row)
end
