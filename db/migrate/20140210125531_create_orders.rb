class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :user, index: true
      t.string :name
      t.string :address
      t.string :phone
      t.string :aasm_state

      t.timestamps
    end
  end
end
