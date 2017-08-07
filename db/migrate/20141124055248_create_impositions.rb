class CreateImpositions < ActiveRecord::Migration
  def change
    create_table :impositions do |t|
      t.belongs_to :spec, index: true
      t.float :paper_width
      t.float :paper_height
      t.text :definition

      t.timestamps
    end
  end
end
