class CreateAuthTokens < ActiveRecord::Migration
  def change
    create_table :auth_tokens do |t|
      t.belongs_to :user
      t.string     :token
      t.json       :extra_info
      t.timestamps
    end

    add_index :auth_tokens, :token, unique: true
  end
end
