class SetFactoryMemberRole < ActiveRecord::Migration
  def change
    role1 = Role.create(name: '帳號管理權限')
    role1.permissions.create(resource: 'FactoryRoleGroup', action: 'index')
    role1.permissions.create(resource: 'FactoryRoleGroup', action: 'create')
    role1.permissions.create(resource: 'FactoryRoleGroup', action: 'update')
    role1.permissions.create(resource: 'FactoryMember', action: 'index')
    role1.permissions.create(resource: 'FactoryMember', action: 'update')

    role2 = Role.create(name: '作業歷程操作')
    role2.permissions.create(resource: 'Order', action: 'delivery_note')
    role2.permissions.create(resource: 'Order', action: 'delivery_note_back')
    role2.permissions.create(resource: 'Order', action: 'sf_express_waybill')
    role2.permissions.create(resource: 'Order', action: 'search')
    role2.permissions.create(resource: 'Order', action: 'history')
    role2.permissions.create(resource: 'OrderItem', action: 'product_ticker')

    role3 = Role.create(name: '拼版設定')
    role3.permissions.create(resource: 'Imposition', action: 'create')
    role3.permissions.create(resource: 'Imposition', action: 'update')
    role3.permissions.create(resource: 'Imposition', action: 'destory')
    role3.permissions.create(resource: 'Imposition', action: 'download')
    role3.permissions.create(resource: 'Imposition', action: 'versions')

    role4 = Role.create(name: '商品生產')
    role4.permissions.create(resource: 'PrintItem', action: 'print')
    role4.permissions.create(resource: 'PrintItem', action: 'reprint_list')
    role4.permissions.create(resource: 'PrintItem', action: 'sublimate')
    role4.permissions.create(resource: 'PrintItem', action: 'delayed')
    role4.permissions.create(resource: 'PrintItem', action: 'reprint')
    role4.permissions.create(resource: 'PrintItem', action: 'download_img')
    role4.permissions.create(resource: 'Order', action: 'delivery_note')
    role4.permissions.create(resource: 'Order', action: 'delivery_note_back')
    role4.permissions.create(resource: 'Order', action: 'package')
    role4.permissions.create(resource: 'Order', action: 'ship')
    role4.permissions.create(resource: 'Order', action: 'update_invoice')
    role4.permissions.create(resource: 'Order', action: 'express')
    role4.permissions.create(resource: 'Order', action: 'sf_express_order')
    role4.permissions.create(resource: 'OrderItem', action: 'product_ticker')
    role4.permissions.create(resource: 'Note', action: 'create')
    role4.permissions.create(resource: 'Note', action: 'update')
    role4.permissions.create(resource: 'TempShelf', action: 'create')
    role4.permissions.create(resource: 'TempShelf', action: 'update')
    role4.permissions.create(resource: 'Imposition', action: 'upload')

    role5 = Role.create(name: '貨架管理')
    role5.permissions.create(resource: 'Shelf', action: 'create')
    role5.permissions.create(resource: 'Shelf', action: 'update')
    role5.permissions.create(resource: 'Shelf', action: 'change')
    role5.permissions.create(resource: 'Shelf', action: 'stock')
    role5.permissions.create(resource: 'Shelf', action: 'move')
    role5.permissions.create(resource: 'Shelf', action: 'activities')
    role5.permissions.create(resource: 'Shelf', action: 'export_csv')
    role5.permissions.create(resource: 'Shelf', action: 'restore')
    role5.permissions.create(resource: 'Shelf', action: 'adjust')
    role5.permissions.create(resource: 'ShelfMaterial', action: 'index')
    role5.permissions.create(resource: 'ShelfMaterial', action: 'create')
    role5.permissions.create(resource: 'ShelfMaterial', action: 'update')
    role5.permissions.create(resource: 'ShelfMaterial', action: 'stock')
    role5.permissions.create(resource: 'ShelfMaterial', action: 'activities')
    role5.permissions.create(resource: 'ShelfMaterial', action: 'adjust')

    role_group = FactoryRoleGroup.create(name: 'Admin')
    role_group.roles << role1
    member = FactoryMember.first
    member.role_groups << role_group if member
  end
end
