class AddColumnOauthSecretTokenInOmniauth < ActiveRecord::Migration
  def change
    add_column :omniauths, :oauth_secret, :string
  end
end
