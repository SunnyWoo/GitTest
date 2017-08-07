class AddCountryCodeToNewsletterSubscriptions < ActiveRecord::Migration
  def change
    add_column :newsletter_subscriptions, :country_code, :string
  end
end
