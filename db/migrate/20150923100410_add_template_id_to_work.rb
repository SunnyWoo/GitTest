class AddTemplateIdToWork < ActiveRecord::Migration
  def change
    add_column :works, :template_id, :integer
  end
end
