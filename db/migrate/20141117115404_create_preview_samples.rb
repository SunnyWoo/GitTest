class CreatePreviewSamples < ActiveRecord::Migration
  def change
    create_table :preview_samples do |t|
      t.belongs_to :preview_composer, index: true
      t.belongs_to :work, index: true
      t.string :result
      t.text :image_meta

      t.timestamps
    end
  end
end
