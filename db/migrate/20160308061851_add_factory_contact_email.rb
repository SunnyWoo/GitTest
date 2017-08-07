class AddFactoryContactEmail < ActiveRecord::Migration
  def change
    add_column :factories, :contact_email, :string
  end
end
