require 'spec_helper'

describe ShelfDecorator do
  context '#material_stock_warning?' do
    context 'return true' do
      Given(:material) { create :shelf_material, quantity: 10, safe_minimum_quantity: 11 }
      Given(:shelf) { create :shelf, material: material }
      Then { shelf.decorate.material_stock_warning? == true }
    end

    context 'return nil' do
      Given(:shelf) { create :shelf, material_id: nil }
      Then { shelf.decorate.material_stock_warning?.nil? }
    end
  end
end
