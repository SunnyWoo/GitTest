class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.belongs_to :user, index: true
      t.string :title
      t.text :body
      t.string :mail_to

      t.timestamps
    end
  end
end
