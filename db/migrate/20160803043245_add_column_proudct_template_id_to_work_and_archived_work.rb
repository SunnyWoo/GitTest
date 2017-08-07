class AddColumnProudctTemplateIdToWorkAndArchivedWork < ActiveRecord::Migration
  def change
    add_column :works, :product_template_id, :integer
    add_column :archived_works, :product_template_id, :integer
    add_column :product_templates, :works_count, :integer, default: 0
    add_column :product_templates, :archived_works_count, :integer, default: 0

    add_index :works, :product_template_id
    add_index :archived_works, :product_template_id
  end
end
