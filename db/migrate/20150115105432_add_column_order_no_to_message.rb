class AddColumnOrderNoToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :order_no, :string
  end
end
