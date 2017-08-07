class CreateWorkCodes < ActiveRecord::Migration
  def change
    create_table :work_codes do |t|
      t.integer :user_id
      t.string :user_type
      t.string :work_type
      t.integer :work_id
      t.string :code
      t.string :product_code

      t.timestamps
    end
  end
end
