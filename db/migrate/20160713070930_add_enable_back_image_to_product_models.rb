class AddEnableBackImageToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :enable_back_image, :boolean, default: false
  end
end
