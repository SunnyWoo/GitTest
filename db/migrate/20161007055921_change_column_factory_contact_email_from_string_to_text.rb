class ChangeColumnFactoryContactEmailFromStringToText < ActiveRecord::Migration
  def change
    change_column :factories, :contact_email, :text
  end
end
