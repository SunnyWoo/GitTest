class ChangeOmniauthsColumn < ActiveRecord::Migration
  def change
    change_column :omniauths, :oauth_token, :text
  end
end
