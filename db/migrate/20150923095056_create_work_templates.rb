class CreateWorkTemplates < ActiveRecord::Migration
  def change
    create_table :work_templates do |t|
      t.integer :work_spec_id
      t.string :background_image
      t.string :overlay_image
      t.string :aasm_state
      t.json :masks

      t.timestamps
    end
  end
end
