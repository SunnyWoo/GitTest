class CreateFees < ActiveRecord::Migration
  def change
    create_table :fees do |t|
      t.string :name
      t.text :description

      t.timestamps
    end
  end
end
