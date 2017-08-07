require 'rails_helper'

RSpec.describe Admin::VariantsController, :admin, type: :controller do
  subject(:product) { create :product_model }

  describe '#index' do
    Given!(:variant) { create :variant, product: product }
    When { get :index, product_model_id: product.slug }
    Then { response.status == 200 }
    And { assigns(:product) == product }
    And { assigns(:variants).include?(variant) }
  end

  describe '#new' do
    When { get :new, product_model_id: product.slug }
    Then { response.status == 200 }
    And { assigns(:product) == product }
    And { assigns(:variant).new_record? }
  end

  describe '#create' do
    context 'success' do
      Given(:option_value) { create :option_value }
      Given(:params) do
        { variant: { option_value_ids: [option_value.id] },
          product_model_id: product.slug }
      end
      When { post :create, params }
      Then { response.status == 302 }
      And { Variant.last.option_values == [option_value] }
    end
  end

  describe '#edit' do
    Given(:variant) { create :variant, product: product }
    When { get :edit, product_model_id: product.slug, id: variant.id }
    Then { response.status == 200 }
    And { assigns(:product) == product }
    And { assigns(:variant) == variant }
  end

  describe '#update' do
    context 'success' do
      Given(:variant) { create :variant, product: product }
      Given(:old_option_value) { create :option_value, variant_ids: [variant.id] }
      Given(:new_option_value) { create :option_value }
      Given(:params) do
        { variant: { option_value_ids: [new_option_value.id] },
          product_model_id: product.slug,
          id: variant.id }
      end
      When { put :update, params }
      Then { response.status == 302 }
      And { variant.reload.option_values == [new_option_value] }
    end
  end
end
