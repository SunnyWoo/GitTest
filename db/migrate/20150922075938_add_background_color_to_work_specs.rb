class AddBackgroundColorToWorkSpecs < ActiveRecord::Migration
  def change
    add_column :work_specs, :background_color, :string, null: false, default: 'white'
  end
end
