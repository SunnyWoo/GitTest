class AddColumnShareTextToWork < ActiveRecord::Migration
  def change
    add_column :works, :share_text, :text
  end
end
