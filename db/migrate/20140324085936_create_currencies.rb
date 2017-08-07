class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :name
      t.string :code
      t.float :price
      t.belongs_to :product_model, index: true

      t.timestamps
    end
  end
end
