class AddPositionsToProductCategories < ActiveRecord::Migration
  def change
    add_column :product_categories, :positions, :json,
               default: { ios: 1, android: 1, website: 1 }
    ProductCategory.find_each do |model|
      model.update!(positions: { ios: model.position, android: model.position, website: model.position })
    end
  end
end
