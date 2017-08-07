class AddWatermarkToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :watermark, :string
  end
end
