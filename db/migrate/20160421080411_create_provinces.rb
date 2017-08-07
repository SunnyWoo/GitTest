class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.integer :area_id
      t.string :name
      t.timestamps
    end

    add_index :provinces, :area_id
  end
end
