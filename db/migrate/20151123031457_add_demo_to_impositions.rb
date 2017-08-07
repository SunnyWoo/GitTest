class AddDemoToImpositions < ActiveRecord::Migration
  def change
    add_column :impositions, :demo, :boolean, null: false, default: false
  end
end
