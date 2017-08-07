require 'rails_helper'

RSpec.describe Admin::ProductCodesController, :admin, type: :controller do
  Given!(:category_code) { create :product_category_code }
  Given!(:product_spec) { create :product_spec }
  Given!(:product_craft) { create :product_craft }
  Given!(:product_material) { create :product_material }

  context '#index' do
    When { get :index }
    Then { response.status == 200 }
  end

  context '#create' do
    context 'create success' do
      Given(:params) do
        {
          admin_product_code_form: {
            code_type: 'spec',
            code: 'A',
            description: 'description'
          }
        }
      end
      When { post :create, params }
      Then { ProductSpec.last.code == 'A' }
      And { ProductSpec.last.description == 'description' }
    end

    context 'fail with invalid code type' do
      Given(:params) do
        {
          admin_product_code_form: {
            code_type: 'invalid',
            code: 'A',
            description: 'description'
          }
        }
      end
      Then { expect { post :create, params }.to raise_error(ActiveRecord::RecordInvalid) }
    end

    context 'fail with code had token' do
      before { create :product_spec, code: 'A'  }
      Given(:params) do
        {
          admin_product_code_form: {
            code_type: 'spec',
            code: 'A',
            description: 'description'
          }
        }
      end
      When { post :create, params }
      Then { flash[:alert] == 'Code 已經被使用' }
    end
  end

  context '#edit' do
    Given!(:product_spec) { create :product_spec, code: 'A', description: 'description' }
    Given(:params) do
      {
        code_type: 'spec',
        id: product_spec.id
      }
    end
    When { xhr :get, :edit, params }
    Then { response.status == 200 }
    And { assigns(:product_code_form).code_type == 'spec' }
    And { assigns(:product_code_form).id == product_spec.id.to_s }
    And { assigns(:product_code_form).description == 'description' }
  end

  context '#update' do
    context 'update spec' do
      Given!(:product_spec) { create :product_spec, description: 'description' }
      Given(:params) do
        {
          id: product_spec.id,
          admin_product_code_form: {
            code_type: 'spec',
            description: 'new description'
          }
        }
      end
      When { xhr :put, :update, params }
      Then { product_spec.reload.description == 'new description' }
    end

    context 'update material' do
      Given!(:product_material) { create :product_material, description: 'description' }
      Given(:params) do
        {
          id: product_material.id,
          admin_product_code_form: {
            code_type: 'material',
            description: 'new description'
          }
        }
      end
      When { xhr :put, :update, params }
      Then { product_material.reload.description == 'new description' }
    end

    context 'update craft' do
      Given!(:product_craft) { create :product_craft, description: 'description' }
      Given(:params) do
        {
          id: product_craft.id,
          admin_product_code_form: {
            code_type: 'craft',
            description: 'new description'
          }
        }
      end
      When { xhr :put, :update, params }
      Then { product_craft.reload.description == 'new description' }
    end

    context 'update category_code' do
      Given!(:category_code) { create :product_category_code, description: 'description' }
      Given(:params) do
        {
          id: category_code.id,
          admin_product_code_form: {
            code_type: 'category_code',
            description: 'new description'
          }
        }
      end
      When { xhr :put, :update, params }
      Then { category_code.reload.description == 'new description' }
    end
  end
end
