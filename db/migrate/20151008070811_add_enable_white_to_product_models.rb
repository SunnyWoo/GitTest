class AddEnableWhiteToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :enable_white, :boolean, default: false
  end
end
