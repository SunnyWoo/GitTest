class CreateWorkSpecs < ActiveRecord::Migration
  def change
    create_table :work_specs do |t|
      t.belongs_to :model, index: true
      t.string :name
      t.text :description
      t.float :width
      t.float :height
      t.integer :dpi, default: 300

      t.timestamps
    end

    ProductModel.find_each do |model|
      WorkSpec.create(model_id: model.id,
                      name: 'cover',
                      width: model.width,
                      height: model.height)
    end
  end

  class ProductModel < ActiveRecord::Base
  end

  class WorkSpec < ActiveRecord::Base
  end
end
