class CreateOmniauths < ActiveRecord::Migration
  def change
    create_table :omniauths do |t|
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.datetime :oauth_expires_at
      t.belongs_to :user, index: true

      t.timestamps
    end
  end
end
