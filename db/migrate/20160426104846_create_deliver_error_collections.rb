class CreateDeliverErrorCollections < ActiveRecord::Migration
  def change
    create_table :deliver_error_collections do |t|
      t.integer :order_id
      t.integer :workable_id
      t.string :workable_type
      t.string :cover_image_url
      t.string :print_image_url
      t.json :error_messages
      t.string :aasm_state

      t.timestamps
    end
  end
end
