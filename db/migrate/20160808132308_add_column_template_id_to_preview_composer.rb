class AddColumnTemplateIdToPreviewComposer < ActiveRecord::Migration
  def change
    add_column :preview_composers, :template_id, :integer
    add_index :preview_composers, :template_id
  end
end
