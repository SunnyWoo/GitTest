require 'spec_helper'

describe Print::StorageForm do
  it { is_expected.to validate_presence_of(:shelf_serial) }
  it { is_expected.to validate_presence_of(:material_serial) }

  Given(:factory) { create :factory }

  context '#stock' do
    context 'When storage exist' do
      Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
      Given(:shelf) { create :shelf, factory: factory, material: material, quantity: 5 }
      Given(:params) do
        { factory_id: factory.id,
          shelf_serial: shelf.serial,
          material_serial: material.serial,
          quantity: 5 }
      end
      Given(:storage) { Print::StorageForm.new(params) }
      When { storage.stock }
      Then { storage.storage == shelf }
      And { shelf.reload.quantity == 10 }
    end

    context 'When storage not exist' do
      Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
      Given(:shelf) { create :shelf, factory: factory }
      Given(:params) do
        { factory_id: factory.id,
          shelf_serial: shelf.serial,
          material_serial: material.serial,
          quantity: 5 }
      end
      Given(:storage) { Print::StorageForm.new(params) }
      When { storage.stock }
      Then { storage.storage == Shelf.last }
      And { Shelf.last.quantity == 5 }
    end
  end

  context '#ship_or_allocate' do
    context 'When storage exist' do
      Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
      Given(:shelf) { create :shelf, factory: factory, material: material, quantity: 5 }
      Given(:params) do
        { factory_id: factory.id,
          shelf_serial: shelf.serial,
          material_serial: material.serial,
          quantity: 5 }
      end
      Given(:storage) { Print::StorageForm.new(params) }
      When { storage.ship_or_allocate }
      Then { storage.storage == shelf }
      And { shelf.reload.quantity == 0 }
      And { material.reload.quantity == 5 }
    end

    context 'When storage not exist' do
      Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
      Given(:shelf) { create :shelf, factory: factory }
      Given(:params) do
        { factory_id: factory.id,
          shelf_serial: shelf.serial,
          material_serial: material.serial,
          quantity: 5 }
      end
      Given(:storage) { Print::StorageForm.new(params) }
      Then { expect { storage.ship_or_allocate }.to raise_error(ActiveRecord::RecordNotFound) }
    end
  end

  context '#move' do
    Given(:material1) { create :shelf_material, factory: factory, quantity: 100 }
    Given(:material2) { create :shelf_material, factory: factory, quantity: 100 }
    Given(:move_from_shelf1) { create :shelf, factory: factory, material: material1, quantity: 5 }
    Given(:move_from_shelf2) { create :shelf, factory: factory, material: material2, quantity: 5 }
    Given(:move_target_shelf1) { create :shelf, factory: factory, material: material2, quantity: 5 }
    Given(:move_target_shelf2) { create :shelf, factory: factory, material: material2, quantity: 5 }
    Given(:move_target_shelf3) { create :shelf, factory: factory, material: material1, quantity: 5 }
    Given(:temp_shelf) { create :shelf, factory: factory, quantity: 0, material: nil }
    context 'When all storage is exist' do
      Given(:params) do
        {
          factory_id: factory.id,
          move_from: {
            a: {
              shelf_serial: move_from_shelf1.serial,
              material_serial: material1.serial,
              quantity: '2'
            },
            b: {
              shelf_serial: move_from_shelf2.serial,
              material_serial: material2.serial,
              quantity: '5'
            }
          },
          move_target: {
            a: {
              shelf_serial: move_target_shelf1.serial,
              material_serial: material2.serial,
              quantity: '2'
            },
            b: {
              shelf_serial: move_target_shelf2.serial,
              material_serial: material2.serial,
              quantity: '3'
            },
            c: {
              shelf_serial: move_target_shelf3.serial,
              material_serial: material1.serial,
              quantity: '2'
            }
          }
        }
      end
      Given(:storage) { Print::StorageForm.new(params) }
      When { storage.move }
      Then { move_from_shelf1.reload.quantity == 3 }
      And { move_from_shelf2.reload.quantity == 0 }
      And { move_target_shelf1.reload.quantity == 7 }
      And { move_target_shelf2.reload.quantity == 8 }
      And { move_target_shelf3.reload.quantity == 7 }
    end

    context 'fails when each material quantity is not eq' do
      Given(:params) do
        {
          factory_id: factory.id,
          move_from: {
            a: {
              shelf_serial: move_from_shelf1.serial,
              material_serial: material1.serial,
              quantity: '2'
            },
            b: {
              shelf_serial: move_from_shelf2.serial,
              material_serial: material2.serial,
              quantity: '5'
            }
          },
          move_target: {
            a: {
              shelf_serial: move_target_shelf1.serial,
              material_serial: material2.serial,
              quantity: '2'
            },
            b: {
              shelf_serial: move_target_shelf2.serial,
              material_serial: material2.serial,
              quantity: '2'
            },
            c: {
              shelf_serial: move_target_shelf3.serial,
              material_serial: material1.serial,
              quantity: '2'
            }
          }
        }
      end
      Given(:storage) { Print::StorageForm.new(params) }
      Then { expect { storage.move }.to raise_error(ArgumentError) }
    end

    context 'When target storage is not exist' do
      Given(:params) do
        {
          factory_id: factory.id,
          move_from: {
            a: {
              shelf_serial: move_from_shelf1.serial,
              material_serial: material1.serial,
              quantity: '2'
            },
            b: {
              shelf_serial: move_from_shelf2.serial,
              material_serial: material2.serial,
              quantity: '5'
            }
          },
          move_target: {
            a: {
              shelf_serial: move_target_shelf1.serial,
              material_serial: material2.serial,
              quantity: '2'
            },
            b: {
              shelf_serial: move_target_shelf2.serial,
              material_serial: material2.serial,
              quantity: '3'
            },
            c: {
              shelf_serial: temp_shelf.serial,
              material_serial: material1.serial,
              quantity: '2'
            }
          }
        }
      end
      Given(:storage) { Print::StorageForm.new(params) }
      When { storage.move }
      Then { move_from_shelf1.reload.quantity == 3 }
      And { move_from_shelf2.reload.quantity == 0 }
      And { move_target_shelf1.reload.quantity == 7 }
      And { move_target_shelf2.reload.quantity == 8 }
      And { temp_shelf.reload.quantity == 2 }
      And { temp_shelf.reload.material == material1 }
    end
  end

  context 'private method' do
    context 'shelf' do
      context 'success when found shelf' do
        Given(:shelf) { create :shelf, factory: factory }
        Given(:storage) { Print::StorageForm.new(factory_id: factory.id, shelf_serial: shelf.serial) }
        Then { storage.send(:shelf) == shelf }
      end

      context 'rails error when not found shelf' do
        Given(:storage) { Print::StorageForm.new(factory_id: factory.id, shelf_serial: 'valid') }
        Then { expect { storage.send(:shelf) }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end

    context 'material' do
      context 'success when found material' do
        Given(:material) { create :shelf_material, factory: factory }
        Given(:storage) { Print::StorageForm.new(factory_id: factory.id, material_serial: material.serial) }
        Then { storage.send(:material) == material }
      end

      context 'rails error when not found material' do
        Given(:storage) { Print::StorageForm.new(factory_id: factory.id, material_serial: 'valid') }
        Then { expect { storage.send(:shelf) }.to raise_error(ActiveRecord::RecordNotFound) }
      end
    end

    context 'find_or_initialize_storage' do
      context 'when storage exist' do
        Given(:material) { create :shelf_material, factory: factory }
        Given(:shelf) { create :shelf, factory: factory, material: material }
        Given(:params) do
          { factory_id: factory.id,
            shelf_serial: shelf.serial,
            material_serial: material.serial
          }
        end
        Given(:storage) { Print::StorageForm.new(params) }
        Then { storage.send(:find_or_initialize_storage) == shelf }
      end

      context 'when storage not exist' do
        Given(:material) { create :shelf_material, factory: factory }
        Given(:shelf) { create :shelf, factory: factory, material: nil }
        Given(:params) do
          { factory_id: factory.id,
            shelf_serial: shelf.serial,
            material_serial: material.serial
          }
        end
        Given(:storage) { Print::StorageForm.new(params) }
        Then { storage.send(:find_or_initialize_storage) == shelf }
        And { shelf.reload.material == material }
      end

      context 'When storage is not exist and the shelf had material' do
        Given(:another_material) { create :shelf_material, factory: factory }
        Given(:material) { create :shelf_material, factory: factory }
        Given(:shelf) { create :shelf, factory: factory, material: another_material }
        Given(:params) do
          { factory_id: factory.id,
            shelf_serial: shelf.serial,
            material_serial: material.serial
          }
        end
        Given(:storage) { Print::StorageForm.new(params) }
        Then { storage.send(:find_or_initialize_storage) == Shelf.last }
        And { Shelf.last.material == material }
      end
    end

    context 'each_material_quantity_of_target' do
      Given(:params) do
        {
          move_target: {
            a: {
              shelf_serial: 'shelf1',
              material_serial: 'material_serial1',
              quantity: '2'
            },
            b: {
              shelf_serial: 'shelf2',
              material_serial: 'material_serial1',
              quantity: '3'
            },
            c: {
              shelf_serial: 'shelf2',
              material_serial: 'material_serial2',
              quantity: '2'
            }
          }
        }
      end

      context 'rails error when not found material' do
        Given(:storage) { Print::StorageForm.new(params) }
        Then { storage.send(:each_material_quantity_of_target) == { material_serial1: 5, material_serial2: 2 } }
      end
    end
  end
end
