class AddColumnIdfaToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :idfa, :string
  end
end
