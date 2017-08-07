class AddPageTypeToMobilePage < ActiveRecord::Migration
  def change
    add_column :mobile_pages, :page_type, :integer
    add_index :mobile_pages, :page_type
  end
end
