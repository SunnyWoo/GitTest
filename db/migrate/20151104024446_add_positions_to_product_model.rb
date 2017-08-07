class AddPositionsToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :positions, :json,
               default: { ios: 1, android: 1, website: 1 }
    ProductModel.find_each do |model|
      model.update!(positions: { ios: model.position, android: model.position, website: model.position })
    end
    remove_column :product_models, :position, :integer
  end
end
