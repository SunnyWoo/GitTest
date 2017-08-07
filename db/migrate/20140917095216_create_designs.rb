class CreateDesigns < ActiveRecord::Migration
  def change
    create_table :designs do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.text :description
      t.string :material

      t.timestamps
    end
  end
end
