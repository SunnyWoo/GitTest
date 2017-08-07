class CreateBillingProfiles < ActiveRecord::Migration

  def change
    create_table :billing_profiles do |t|
      t.string :address
      t.string :city
      t.string :name
      t.string :phone
      t.string :state
      t.string :zip_code
      t.string :country
      t.belongs_to :billable, polymorphic: true

      t.timestamps
    end
    add_index :billing_profiles, [:billable_id, :billable_type]
    remove_column :orders, :address, :string
    remove_column :orders, :name, :string
    remove_column :orders, :phone, :string
  end

end
