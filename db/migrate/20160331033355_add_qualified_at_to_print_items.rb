class AddQualifiedAtToPrintItems < ActiveRecord::Migration
  def change
    add_column :print_items, :qualified_at, :datetime
    add_column :print_histories, :qualified_at, :datetime
  end
end
