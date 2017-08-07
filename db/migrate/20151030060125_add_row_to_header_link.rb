class AddRowToHeaderLink < ActiveRecord::Migration
  def change
    add_column :header_links, :row, :integer
  end
end
