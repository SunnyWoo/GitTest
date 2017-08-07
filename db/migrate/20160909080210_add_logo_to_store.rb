class AddLogoToStore < ActiveRecord::Migration
  def change
    add_column :stores, :logo, :string
  end
end
