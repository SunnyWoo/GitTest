require 'rails_helper'

RSpec.describe Admin::ProductModelsController, :admin, type: :controller do
  Given!(:spec) { create :product_spec, code: 'A' }
  Given!(:craft) { create :product_craft, code: '1' }
  Given!(:material) { create :product_material, code: 'PCG' }

  context '#new' do
    When { get :new }
    Then { response.status == 200 }
    And { assigns(:specs) == { "#{spec.code} (#{spec.description})" => spec.id } }
    And { assigns(:crafts) == { "#{craft.code} (#{craft.description})" => craft.id } }
    And { assigns(:materials) == { "#{material.code} (#{material.description})" => material.id } }
  end

  context '#edit' do
    Given(:product) { create :product_model }
    When { get :edit, id: product.id }
    Then { response.status == 200 }
    And { assigns(:resource) == product }
    And { assigns(:specs) == { "#{spec.code} (#{spec.description})" => spec.id } }
    And { assigns(:crafts) == { "#{craft.code} (#{craft.description})" => craft.id } }
    And { assigns(:materials) == { "#{material.code} (#{material.description})" => material.id } }
  end
end
