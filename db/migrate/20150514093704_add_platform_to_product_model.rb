class AddPlatformToProductModel < ActiveRecord::Migration
  def change
    add_column :product_models, :design_platform, :json,
               default: { ios: false, android: false, website: false }
    add_column :product_models, :customize_platform, :json,
               default: { ios: false, android: false, website: false }
  end
end

