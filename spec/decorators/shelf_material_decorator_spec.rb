require 'spec_helper'

describe ShelfMaterialDecorator do
  context '#stock_warning?' do
    context 'return true' do
      Given(:material) { create :shelf_material, quantity: 10, safe_minimum_quantity: 11 }
      Then { material.decorate.stock_warning? == true }
    end

    context 'return true' do
      Given(:material) { create :shelf_material, quantity: 10, safe_minimum_quantity: 9 }
      Then { material.decorate.stock_warning? == false }
    end
  end
end
