class AllowNullForSerializedColumns < ActiveRecord::Migration
  def up
    change_column :archived_standardized_works, :image_meta, :json, null: true, default: nil
    change_column :coupon_notices, :platform, :json, null: true, default: nil
    change_column :coupon_notices, :region, :json, null: true, default: nil
    change_column :logcraft_activities, :source, :json, null: true, default: nil
    change_column :logcraft_activities, :extra_info, :json, null: true, default: nil
    change_column :mobile_components, :contents, :json, null: true, default: nil
    change_column :mobile_pages, :contents, :json, null: true, default: nil
    change_column :designers, :image_meta, :json, null: true, default: nil
    change_column :product_models, :design_platform, :json, null: true, default: nil
    change_column :product_models, :customize_platform, :json, null: true, default: nil
    change_column :product_models, :extra_info, :json, null: true, default: nil
    change_column :standardized_works, :image_meta, :json, null: true, default: nil
    change_column :works, :image_meta, :json, null: true, default: nil
    change_column :work_output_files, :image_meta, :json, null: true, default: nil
    change_column :order_items, :remote_info, :json, null: true, default: nil
    change_column :orders, :remote_info, :json, null: true, default: nil
    change_column :bdevent_products, :info, :json, null: true, default: nil
    change_column :bdevent_works, :info, :json, null: true, default: nil
  end

  def down
  end
end
