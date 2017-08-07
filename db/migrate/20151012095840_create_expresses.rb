class CreateExpresses < ActiveRecord::Migration
  def change
    create_table :expresses do |t|
      t.string :code, default: ''
      t.string :name, default: ''
      t.timestamps
    end

    add_index :expresses, %i(code), unique: true

    add_column :orders, :express_id, :integer
  end
end
