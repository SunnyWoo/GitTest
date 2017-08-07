class AddFieldsToWorkSpec < ActiveRecord::Migration
  def change
    add_column :work_specs, :variant_id, :integer
    add_column :work_specs, :dir_name, :string
    add_column :work_specs, :placeholder_image, :string
    add_column :work_specs, :enable_white, :boolean, default: false
    add_column :work_specs, :auto_imposite, :boolean, default: false
    add_column :work_specs, :watermark, :string
    add_column :work_specs, :print_image_mask, :string
    add_column :work_specs, :enable_composite_with_horizontal_rotation, :boolean, default: false
    add_column :work_specs, :create_order_image_by_cover_image, :boolean, default: false
    add_column :work_specs, :enable_back_image, :boolean, default: false

    add_index :work_specs, :variant_id, unique: true
  end
end
