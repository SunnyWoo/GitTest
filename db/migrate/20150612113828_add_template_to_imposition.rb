class AddTemplateToImposition < ActiveRecord::Migration
  def change
    add_column :impositions, :template, :string
  end
end
