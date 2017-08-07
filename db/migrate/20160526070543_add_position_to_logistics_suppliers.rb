class AddPositionToLogisticsSuppliers < ActiveRecord::Migration
  def change
    add_column :logistics_suppliers, :position, :integer

    if Region.china?
      LogisticsSupplier.create(name: 'EMS')
      %w(圆通 韵达 顺丰特惠 顺丰标快 EMS 其它).each_with_index do |name, index|
        logistics_supplier = LogisticsSupplier.find_by(name: name)
        logistics_supplier.update(position: index + 1) if logistics_supplier
      end
    else
      %w(順豐 EMS 其它).each_with_index do |name, index|
        logistics_supplier = LogisticsSupplier.find_by(name: name)
        logistics_supplier.update(position: index + 1) if logistics_supplier
      end
    end
  end
end
