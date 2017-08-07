class AddUsernameToOmniauths < ActiveRecord::Migration
  def change
    add_column :omniauths, :username, :string
  end
end
