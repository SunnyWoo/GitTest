class AddAuthTokensUserIdIndex < ActiveRecord::Migration
  def change
    add_index :auth_tokens, :user_id
  end
end
