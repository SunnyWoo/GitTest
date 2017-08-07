class AddDirNameToProductModels < ActiveRecord::Migration
  def change
    add_column :product_models, :dir_name, :string

    ProductModel.find_each do |model|
      model.update(dir_name: model.key)
    end
  end

  class ProductModel < ActiveRecord::Base
  end
end
