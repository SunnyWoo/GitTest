class AddDefaultFilterToLayers < ActiveRecord::Migration
  def change
    change_column_default :layers, :filter, 0
    reversible do |dir|
      dir.up do
        Layer.all.each do |layer|
          if !layer.filter.present?
            layer.update_attribute(:filter, 0)
          end
        end
      end
    end
  end
end
