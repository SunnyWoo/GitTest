class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.belongs_to :user, index: true
      t.belongs_to :work, index: true, polymorphic: true
      t.text :body
      t.integer :star

      t.timestamps
    end
  end
end
