class RenameSpecImages < ActiveRecord::Migration
  def change
    rename_column :work_specs, :web_alpha_mask, :background_image
    rename_column :work_specs, :web_editor_background, :overlay_image
  end
end
