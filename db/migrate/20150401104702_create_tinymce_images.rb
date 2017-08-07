class CreateTinymceImages < ActiveRecord::Migration
  def change
    create_table :tinymce_images do |t|
      t.string :file
      t.timestamps
    end
  end
end
