require 'spec_helper'

RSpec.describe Print::TempShelvesController, type: :request do
  before do
    role = Role.create(name: 'TempShelf')
    role.permissions.create(resource: 'TempShelf', action: 'create')
    role.permissions.create(resource: 'TempShelf', action: 'update')
    role_group = FactoryRoleGroup.create(name: 'Admin')
    role_group.roles << role
  end

  before do
    login_factory_member
    member = FactoryMember.last
    member.role_groups = [FactoryRoleGroup.last]
  end

  describe '#new' do
    Given(:temp_shelf) { create(:temp_shelf) }
    context 'success' do
      When { xhr :get, new_print_temp_shelf_path(print_item_id: temp_shelf.print_item_id, locale: 'zh-CN') }
      Then { response.status == 200 }
    end

    context 'invalid print_item_id' do
      When { xhr :get, new_print_temp_shelf_path(print_item_id: 0, locale: 'zh-CN') }
      Then { response.status == 404 }
    end
  end

  describe '#create' do
    Given(:print_item) { create(:print_item, :with_sublimated) }
    Given(:temp_shelf_params) do
      {
        print_item_id: print_item.id,
        temp_shelf: {
          serial: 'serial_001',
          description: 'description_001'
        }
      }
    end

    context 'success' do
      When { post print_temp_shelves_path(temp_shelf_params) }
      Then { TempShelf.count == 1 }
      And { TempShelf.last.serial == 'serial_001' }
      And { TempShelf.last.description == 'description_001' }
    end

    context 'invalid print_item_id' do
      When { post print_temp_shelves_path(temp_shelf_params.merge(print_item_id: 0, serial: 'serial')) }
      Then { TempShelf.count == 0 }
      And { response.status == 404 }
    end
  end

  describe '#edit' do
    Given(:temp_shelf) { create(:temp_shelf) }
    context 'success' do
      Given(:request_params) { { print_item_id: temp_shelf.print_item_id, locale: 'zh-CN', serial: 'serial' } }
      When { xhr :get, edit_print_temp_shelf_path(temp_shelf, request_params) }
      Then { response.status == 200 }
    end

    context 'invalid print_item_id' do
      When { xhr :get, edit_print_temp_shelf_path(temp_shelf, print_item_id: 0, locale: 'zh-CN', serial: 'serial') }
      Then { response.status == 404 }
    end
  end

  describe '#update' do
    Given(:temp_shelf) { create(:temp_shelf) }
    Given(:temp_shelf_params) do
      {
        print_item_id: temp_shelf.print_item.id,
        temp_shelf: {
          serial: 'serial_003',
          description: 'description'
        }
      }
    end

    context 'success' do
      When { patch print_temp_shelf_path(temp_shelf, temp_shelf_params) }
      Then { temp_shelf.reload.serial == 'serial_003' }
      And { temp_shelf.reload.description == 'description' }
    end

    context 'invalid print_item_id' do
      When { patch print_temp_shelf_path(temp_shelf, temp_shelf_params.merge(print_item_id: 0)) }
      Then { response.status == 404 }
    end
  end
end
