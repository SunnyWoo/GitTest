class DeviseCreateDesigners < ActiveRecord::Migration
  def change
    create_table(:designers) do |t|
      ## Database authenticatable
      t.string :username,           null: false, default: ''
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      t.string   :display_name
      t.string   :avatar
      t.text     :description
      t.json     :image_meta, default: {}

      t.timestamps
    end

    add_index :designers, :email,                unique: true
    add_index :designers, :reset_password_token, unique: true
  end
end
