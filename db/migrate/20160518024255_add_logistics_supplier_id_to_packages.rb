class AddLogisticsSupplierIdToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :logistics_supplier_id, :integer

    LogisticsSupplier.create(name: '其它')
  end
end
