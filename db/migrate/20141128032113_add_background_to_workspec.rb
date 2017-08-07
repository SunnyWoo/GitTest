class AddBackgroundToWorkspec < ActiveRecord::Migration
  def change
    add_column :work_specs, :web_alpha_mask, :string
    add_column :work_specs, :web_editor_background, :string
  end
end
