require 'spec_helper'

describe Print::ShelvesController, type: :controller do
  Given(:factory) { create :factory }
  Given(:factory_member) { create :factory_member, factory: factory }
  Given!(:shelf) { create :shelf, factory: factory }

  before { sign_in factory_member }

  context '#index' do
    When { get :index }
    Then { response.status == 200 }
    And { assigns(:shelves) == [shelf] }
  end

  context '#show' do
    When { get :show, id: shelf.id }
    Then { response.status == 200 }
    And { assigns(:shelf) == shelf }
  end

  context '#new' do
    before { allow(controller).to receive(:authorize).with(Shelf, :create?) }
    When { get :new }
    Then { response.status == 200 }
  end

  context '#create' do
    before { allow(controller).to receive(:authorize).with(Shelf, :create?) }
    Given(:category) { create :shelf_category }
    When { post :create, shelf: { serial: 'abcdefg', category_id: category.id } }
    Then { Shelf.last.serial == 'abcdefg' }
    And { Shelf.last.category == category }
  end

  context '#edit' do
    before { allow(controller).to receive(:authorize).with(Shelf, :update?) }
    When { get :edit, id: shelf.id }
    Then { response.status == 200 }
    And { assigns(:shelf) == shelf }
  end

  context '#put' do
    before { allow(controller).to receive(:authorize).with(Shelf, :update?) }
    Given(:category) { create :shelf_category }
    When { put :update, id: shelf.id, shelf: { serial: 'abcdefg', category_id: category.id } }
    Then { shelf.reload.serial == 'abcdefg' }
    And { shelf.reload.category == category }
  end

  context '#changing' do
    before { allow(controller).to receive(:authorize).with(Shelf, :change?) }
    context 'when adjusting' do
      before { Print::StoragePolicyService.start_adjust }
      When { get :changing, changing_action: 'ship' }
      Then { response.status == 302 }
    end

    context 'success' do
      When { get :changing, changing_action: 'ship' }
      Then { response.status == 200 }
    end
  end

  context '#change' do
    before { allow(controller).to receive(:authorize).with(Shelf, :change?) }
    before do
      request.env['HTTP_REFERER'] = print_shelves_path
    end
    Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
    Given(:shelf) { create :shelf, material: material, factory: factory, quantity: 5 }
    Given(:params) do
      {
        changing_action: 'ship',
        print_storage_form: {
          shelf_serial: shelf.serial,
          material_serial: material.serial,
          quantity: 2,
          message: 'change'
        }
      }
    end
    When { put :change, params }
    Then { shelf.reload.quantity == 3 }
    And { material.reload.quantity == 8 }
    And { shelf.activities.last.key == 'ship' }
    And { shelf.activities.last.message == 'change' }
  end

  context 'seek' do
    Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
    Given(:shelf_with_material) { create :shelf, material: material, factory: factory, quantity: 5 }
    Given(:shelf) { create :shelf, material: nil, factory: factory, quantity: 5 }
    context 'seek shelf' do
      When { get :seek, serial: shelf.serial }
      Then { response_json['shelf']['id'] == shelf.id }
    end

    context 'seek shelf with material' do
      context 'seek shelf' do
        When { get :seek, shelf_serial: shelf_with_material.serial, material_serial: material.serial }
        Then { response_json['shelf']['id'] == shelf_with_material.id }
      end
    end
  end

  context '#restoring' do
    before { allow(controller).to receive(:authorize).with(Shelf, :restore?) }
    When { get :restoring }
    Then { response.status == 200 }
  end

  context '#restore' do
    before { allow(controller).to receive(:authorize).with(Shelf, :restore?) }
    Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
    Given(:shelf) { create :shelf, material: material, factory: factory, quantity: 5 }
    Given(:params) do
      {
        print_storage_form: {
          shelf_serial: shelf.serial,
          material_serial: material.serial,
          quantity: 10,
          message: 'restore'
        }
      }
    end
    When { put :restore, params }
    Then { shelf.reload.quantity == 15 }
    And { material.reload.quantity == 20 }
    And { shelf.activities.last.key == 'restore' }
    And { shelf.activities.last.message == 'restore' }
  end

  context '#stocking' do
    before { expect(controller).to receive(:authorize).with(Shelf, :stock?) }
    When { get :stocking }
    Then { response.status == 200 }
  end

  context '#stock' do
    before { expect(controller).to receive(:authorize).with(Shelf, :stock?) }
    before { request.env['HTTP_REFERER'] = print_shelves_path }
    Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
    Given(:shelf) { create :shelf, material: material, factory: factory, quantity: 5 }
    Given(:params) do
      {
        print_storage_form: {
          shelf_serial: shelf.serial,
          material_serial: material.serial,
          quantity: 2,
          message: 'stock'
        }
      }
    end
    When { put :stock, params }
    Then { shelf.reload.quantity == 7 }
    And { material.reload.quantity == 10 }
    And { shelf.activities.last.key == 'stock' }
    And { shelf.activities.last.message == 'stock' }
  end

  context '#adjusting' do
    before { allow(controller).to receive(:authorize).with(Shelf, :adjust?) }
    Given!(:shelf) { create :shelf, material: nil, factory: factory, quantity: 5 }
    Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
    Given!(:shelf_with_material) { create :shelf, material: material, factory: factory, quantity: 5 }
    When { get :adjusting }
    Then { response.status == 200 }
    And { assigns(:shelves) == [shelf_with_material] }
  end

  context '#adjust' do
    before { allow(controller).to receive(:authorize).with(Shelf, :adjust?) }
    Given(:material) { create :shelf_material, factory: factory, quantity: 10 }
    Given(:shelf1) { create :shelf, material: material, factory: factory, quantity: 2 }
    Given(:shelf2) { create :shelf, material: material, factory: factory, quantity: 2 }
    Given(:params) do
      {
        storage: {
          "#{shelf1.id}" => { quantity: 3 },
          "#{shelf2.id}" => { quantity: 4 }
        },
        message: 'adjust'
      }
    end
    When { put :adjust, params }
    Then { response.status == 302 }
    And { shelf1.reload.quantity == 3 }
    And { shelf2.reload.quantity == 4 }
    And { Print::StoragePolicyService.storage_lock? == false }
    And { shelf1.activities.last.key == 'adjust' }
    And { shelf1.activities.last.message == 'adjust' }
    And { shelf2.activities.last.key == 'adjust' }
    And { shelf2.activities.last.message == 'adjust' }
  end

  context '#start_adjust' do
    before { allow(controller).to receive(:authorize).with(Shelf, :adjust?) }
    When { get :start_adjust }
    Then { Print::StoragePolicyService.storage_lock? == true }
  end

  context '#finish_adjust' do
    before { allow(controller).to receive(:authorize).with(Shelf, :adjust?) }
    When { get :finish_adjust }
    Then { Print::StoragePolicyService.storage_lock? == false }
  end

  context '#moving' do
    before { expect(controller).to receive(:authorize).with(Shelf, :move?) }
    When { get :moving }
    Then { response.status == 200 }
  end

  context '#move' do
    before { expect(controller).to receive(:authorize).with(Shelf, :move?) }
    Given(:material1) { create :shelf_material, factory: factory, quantity: 100 }
    Given(:material2) { create :shelf_material, factory: factory, quantity: 100 }
    Given(:move_from_shelf1) { create :shelf, factory: factory, material: material1, quantity: 5 }
    Given(:move_from_shelf2) { create :shelf, factory: factory, material: material2, quantity: 5 }
    Given(:move_target_shelf1) { create :shelf, factory: factory, material: material2, quantity: 5 }
    Given(:move_target_shelf2) { create :shelf, factory: factory, material: material2, quantity: 5 }
    Given(:move_target_shelf3) { create :shelf, factory: factory, material: material1, quantity: 5 }
    Given(:params) do
      {
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
        },
        message: 'move'
      }
    end
    before { request.env['HTTP_REFERER'] = print_shelves_path }
    When { put :move, params }
    Then { move_from_shelf1.reload.quantity == 3 }
    And { move_from_shelf2.reload.quantity == 0 }
    And { move_target_shelf1.reload.quantity == 7 }
    And { move_target_shelf2.reload.quantity == 8 }
    And { move_target_shelf3.reload.quantity == 7 }
    And { move_from_shelf1.activities.last.key == 'move_out' }
    And { move_from_shelf1.activities.last.message == 'move' }
    And { move_from_shelf2.activities.last.key == 'move_out' }
    And { move_from_shelf2.activities.last.message == 'move' }
    And { move_target_shelf1.activities.last.key == 'move_in' }
    And { move_target_shelf1.activities.last.message == 'move' }
    And { move_target_shelf2.activities.last.key == 'move_in' }
    And { move_target_shelf2.activities.last.message == 'move' }
    And { move_target_shelf3.activities.last.key == 'move_in' }
    And { move_target_shelf3.activities.last.message == 'move' }
  end
end
