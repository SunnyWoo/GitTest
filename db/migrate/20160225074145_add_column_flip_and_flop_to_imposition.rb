class AddColumnFlipAndFlopToImposition < ActiveRecord::Migration
  def change
    add_column :impositions, :flip, :boolean, default: false
    add_column :impositions, :flop, :boolean, default: false
  end
end
