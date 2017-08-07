class AddUserTypeToNote < ActiveRecord::Migration
  def change
    add_column :notes, :user_type, :string
    Note.where(user_type: nil).update_all(user_type: 'Admin')
  end
end
