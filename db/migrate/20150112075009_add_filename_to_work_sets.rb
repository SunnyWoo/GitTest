class AddFilenameToWorkSets < ActiveRecord::Migration
  def change
    add_column :work_sets, :zip_filename, :string
    add_column :work_sets, :zip_entry_filenames, :string, array: true, default: []
  end
end
