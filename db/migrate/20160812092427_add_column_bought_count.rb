class AddColumnBoughtCount < ActiveRecord::Migration
  def change
    add_column :standardized_works, :bought_count, :integer, default: 0
  end
end
