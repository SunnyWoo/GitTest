class AddStateToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :state, :integer, default: 0
  end
end
