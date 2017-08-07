class CreateCpResources < ActiveRecord::Migration
  def change
    create_table :cp_resources do |t|
      t.integer :version
      t.string :aasm_state
      t.datetime :publish_at
      t.json :list_urls
      t.string :small_package
      t.string :large_package
      t.json :memo

      t.timestamps null: false
    end
  end
end
