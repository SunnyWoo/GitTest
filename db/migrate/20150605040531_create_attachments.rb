class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :file_uid
      t.json :file_meta

      t.timestamps
    end
  end
end
