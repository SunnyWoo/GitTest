class CreatePreviewComposers < ActiveRecord::Migration
  def change
    create_table :preview_composers do |t|
      t.string :type
      t.belongs_to :model, index: true
      t.text :layers

      t.timestamps
    end
  end
end
