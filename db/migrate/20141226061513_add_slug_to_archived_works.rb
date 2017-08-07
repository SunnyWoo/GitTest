class AddSlugToArchivedWorks < ActiveRecord::Migration
  def change
    add_column :archived_works, :slug, :string
  end
end
