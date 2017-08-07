class CreateNewsletterSubscriptions < ActiveRecord::Migration
  def change
    create_table :newsletter_subscriptions do |t|
      t.string  :email
      t.string  :locale
      t.boolean :is_enabled, default: true
      t.timestamps
    end

    add_index :newsletter_subscriptions, :email, unique: true
    add_index :newsletter_subscriptions, [:email, :is_enabled]
  end
end
