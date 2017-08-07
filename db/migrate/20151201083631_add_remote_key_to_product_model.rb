class AddRemoteKeyToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :remote_key, :string
  end
end
