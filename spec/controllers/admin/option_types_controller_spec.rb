require 'rails_helper'

RSpec.describe Admin::OptionTypesController, :admin, type: :controller do
  describe '#index' do
    Given!(:option_type) { create :option_type }
    When { get :index }
    Then { response.status == 200 }
    And { assigns(:option_types) == [option_type] }
  end

  describe '#new' do
    When { get :new }
    Then { response.status == 200 }
    And { assigns(:option_type).new_record? }
  end

  describe '#create' do
    context 'success' do
      Given(:params) do
        { option_type: { name: 'name',
                         presentation: 'presentation' } }
      end
      When { post :create, params }
      Then { response.status == 302 }
      And { OptionType.last.name == 'name' }
      And { OptionType.last.presentation == 'presentation' }
    end

    context 'failed' do
      Given(:params) do
        { option_type: { name: '', presentation: '' } }
      end
      When { post :create, params }
      Then { flash[:error].present? }
    end
  end

  describe '#show' do
    Given(:option_type) { create :option_type }
    When { get :show, id: option_type.id }
    Then { response.status == 200 }
    And { assigns(:option_type) == option_type }
  end

  describe '#edit' do
    Given(:option_type) { create :option_type }
    When { get :edit, id: option_type.id }
    Then { response.status == 200 }
    And { assigns(:option_type) == option_type }
  end

  describe '#update' do
    Given(:option_type) { create :option_type }

    context 'success' do
      Given(:params) { { name: 'edit_name', presentation: 'presentation' } }
      When { put :update, id: option_type.id, option_type: params }
      Then { response.status == 302 }
      And { option_type.reload.name == 'edit_name' }
    end

    context 'failed' do
      Given(:params) { { name: 'edit_name', presentation: '' } }
      When { put :update, id: option_type.id, option_type: params }
      Then { flash[:error].present? }
      And { option_type.reload.name != 'edit_name' }
    end
  end
end
