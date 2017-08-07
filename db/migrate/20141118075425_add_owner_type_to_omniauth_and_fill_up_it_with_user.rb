class AddOwnerTypeToOmniauthAndFillUpItWithUser < ActiveRecord::Migration
  def up
    add_column :omniauths, :owner_type, :string
    rename_column :omniauths, :user_id, :owner_id
    Omniauth.update_all(owner_type: "User")
  end

  def down
    remove_column :omniauths, :owner_type
    rename_column :omniauths, :owner_id, :user_id
  end
end
