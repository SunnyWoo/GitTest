class AddPayableToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :payable_id, :integer
    add_column :currencies, :payable_type, :string
    add_index :currencies, :payable_id
    add_index :currencies, :payable_type
  end
end
