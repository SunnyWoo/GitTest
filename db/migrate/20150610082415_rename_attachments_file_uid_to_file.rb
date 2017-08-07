class RenameAttachmentsFileUidToFile < ActiveRecord::Migration
  def change
    rename_column :attachments, :file_uid, :file
  end
end
