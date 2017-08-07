class AddAiAndPdfToWorks < ActiveRecord::Migration
  def change
    add_column :works, :ai, :string
    add_column :works, :pdf, :string
    add_column :archived_works, :ai, :string
    add_column :archived_works, :pdf, :string
  end
end
