require 'spec_helper'

describe Print::PickingsController, type: :controller do
  Given(:factory) { create :factory }
  Given(:factory_member) { create :factory_member, factory: factory }
  Given!(:shelf) { create :shelf, factory: factory }
  Given!(:product) { create :product_model }
  before do
    sign_in factory_member
  end

  context '#index' do
    context 'model_id is present' do
      When { get :index, model_id: product.id }
      Then { response.status == 200 }
      And { assigns(:product_model) == product }
    end

    context 'model_id is blank' do
      When { get :index }
      Then { response.status == 200 }
      And { assigns(:product_model) == product }
    end
  end

  context '#update' do
    before { expect(controller).to receive(:authorize).with(ProductModel, :pick?) }
    context 'create' do
      before { request.env['HTTP_REFERER'] = print_pickings_path }
      Given(:update_params) do
        { picking_materials_attributes: {
          '0' => {
            material: 'material',
            quantity: '1',
            _destroy: 'false'
          }
        } }
      end
      When { get :update, model_id: product.id, product_model: update_params }
      Then { response.status == 302 }
      And { product.picking_materials.size == 1 }
    end

    context 'update' do
      before do
        request.env['HTTP_REFERER'] = print_pickings_path
      end
      Given!(:picking_material) { create :picking_material, product: product }
      Given(:update_params) do
        { picking_materials_attributes: {
          '0' => {
            material: 'update_material',
            quantity: '1',
            _destroy: 'false',
            id: picking_material.id
          }
        } }
      end
      When { get :update, model_id: product.id, product_model: update_params }
      Then { response.status == 302 }
      And { picking_material.reload.material == 'update_material' }
    end

    context 'destroy' do
      before do
        request.env['HTTP_REFERER'] = print_pickings_path
      end
      Given!(:picking_material) { create :picking_material, product: product }
      Given(:update_params) do
        { picking_materials_attributes: {
          '0' => {
            material: 'update_material',
            quantity: '1',
            _destroy: 'true',
            id: picking_material.id
          }
        } }
      end
      When { get :update, model_id: product.id, product_model: update_params }
      Then { response.status == 302 }
      And { product.picking_materials.size == 0 }
    end
  end
end
