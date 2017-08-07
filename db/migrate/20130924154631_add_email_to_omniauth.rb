class AddEmailToOmniauth < ActiveRecord::Migration
  def change
    add_column :omniauths, :email, :string
  end
end
