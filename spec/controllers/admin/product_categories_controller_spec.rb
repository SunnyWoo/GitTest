require 'rails_helper'

RSpec.describe Admin::ProductCategoriesController, :admin, type: :controller do
  Given(:category) { create :product_category }
  Given!(:category_code) { create :product_category_code, code: 'CA' }

  context '#new' do
    When { xhr :get, :new, format: :js }
    Then { response.status == 200 }
    And { assigns(:category_codes) == [['CA', category_code.id]] }
  end

  context '#edit' do
    When { xhr :get, :edit, id: category.id, format: :js }
    Then { response.status == 200 }
    And { assigns(:category) == category }
    And { assigns(:category_codes) == [['CA', category_code.id]] }
  end

  context '#update' do
    context 'update success' do
      Given!(:category) { create :product_category, key: 'before' }
      Given(:params) do
        {
          id: category.id,
          category: {
            key: 'update',
            image: fixture_file_upload('test.jpg', 'image/jpeg'),
          }
        }
      end
      When { xhr :put, :update, params, format: :js }
      Then { response.status == 200 }
      Then { category.reload.key == 'update' }
      And { category.reload.image.url.present? }
    end
  end

  context '#create' do
    context 'create success' do
      Given(:params) do
        {
          category: {
            key: 'ABC',
            image: fixture_file_upload('test.jpg', 'image/jpeg')
          }
        }
      end
      When { xhr :post, :create, params, format: :js }
      Then { response.status == 200 }
      Then { ProductCategory.last.key == 'ABC' }
      And { ProductCategory.last.image.url.present? }
    end
  end
end
