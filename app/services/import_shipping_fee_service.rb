class ImportShippingFeeService
  class << self
    def import
      if Region.china?
        import_china_shipping_fee
      else
        import_global_shipping_fee
      end
    end

    def import_china_shipping_fee
      logistics_suppliers = {}
      CSV.foreach('db/fixtures/data/shipping_fee_china.csv') do |row|
        logistics_suppliers = row and next if row[0] == 'Area'

        area = Area.find_or_create_by(name: row[0])
        province = area.provinces.find_or_create_by(name: row[1])

        (2..9).each do |index|
          next if row[index].blank?
          logistics_supplier = LogisticsSupplier.find_or_create_by(name: logistics_suppliers[index])
          type = index.even? ? 'ShippingFee::Normal' : 'ShippingFee::Overweight'
          create_shipping_fee(logistics_supplier, type, row[index], province: province)
        end
      end
    end

    def import_global_shipping_fee
      logistics_suppliers = {}
      countries = {}
      CSV.foreach('db/fixtures/data/shipping_fee_global.csv') do |row|
        logistics_suppliers = row and next if row[0] == 'logistics_supplier'
        countries = row and next if row[0] == 'country'

        (1..14).each do |index|
          logistics_supplier_name = logistics_suppliers[index]
          logistics_supplier = LogisticsSupplier.find_or_create_by(name: logistics_supplier_name)
          if row[0] != 'overweight'
            weight = row[0].to_f * 1000
            type = 'ShippingFee::Normal'
          else
            weight = 1000
            type = 'ShippingFee::Overweight'
          end
          create_shipping_fee(logistics_supplier, type, row[index], country: countries[index], weight: weight)
        end
      end
    end

    def create_shipping_fee(logistics_supplier, type, price, country: 'CN', weight: 1000, province: nil)
      ShippingFee.find_or_create_by(type: type,
                                    province: province,
                                    logistics_supplier: logistics_supplier,
                                    country: country,
                                    currency: currency,
                                    weight: weight,
                                    price: price
                                   )
    end

    def currency
      Region.china? ? 'CNY' : 'TWD'
    end
  end
end
