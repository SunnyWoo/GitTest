class AddColumnDescriptionToStandardizedWorkAndProductTemplate < ActiveRecord::Migration
  def change
    add_column :standardized_works, :content, :text
    add_column :product_templates, :description, :text
  end
end
