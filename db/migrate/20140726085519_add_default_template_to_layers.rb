class AddDefaultTemplateToLayers < ActiveRecord::Migration
  def change
    change_column_default :layers, :orientation, 0.0
    change_column_default :layers, :position_x, 0.0
    change_column_default :layers, :position_y, 0.0
    change_column_default :layers, :scale_x, 1.0
    change_column_default :layers, :scale_y, 1.0
    change_column_default :layers, :transparent, 1.0
  end
end
