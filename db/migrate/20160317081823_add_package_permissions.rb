class AddPackagePermissions < ActiveRecord::Migration
  def change
    # Add
    role1 = Role.find_by(name: '作業歷程操作')
    if role1
      role1.permissions.create(resource: 'Package', action: 'delivery_note')
      role1.permissions.create(resource: 'Package', action: 'sf_express_waybill')
    end

    role2 = Role.find_by(name: '商品生產')
    if role2
      role2.permissions.create(resource: 'Package', action: 'delivery_note')
      role2.permissions.create(resource: 'Package', action: 'create')
      role2.permissions.create(resource: 'Package', action: 'ship')
      role2.permissions.create(resource: 'Package', action: 'sf_express')
      role2.permissions.create(resource: 'PrintItem', action: 'receive')
    end

    # Delete
    delete_permissions = %i(ship express sf_express_order sf_express_waybill)
    Permission.where(resource: 'Order', action: delete_permissions).delete_all
  end
end
