class CreateMarketings < ActiveRecord::Migration
  def change
    create_table :marketings do |t|
      t.string :email

      t.timestamps
    end
    add_index :marketings, :email
  end
end
