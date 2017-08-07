class AddColumnFileToImposition < ActiveRecord::Migration
  def change
    add_column :impositions, :file, :string
  end
end
