class AddCodeToDesigner < ActiveRecord::Migration
  def change
    add_column :designers, :code, :string
  end
end
