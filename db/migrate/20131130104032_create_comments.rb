class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :email
      t.text :content
      t.boolean :is_admin, default: false

      t.timestamps
    end
  end
end
