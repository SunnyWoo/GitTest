class AddShapeToWorkSpecs < ActiveRecord::Migration
  def change
    add_column :work_specs, :shape, :string

    WorkSpec.find_each do |spec|
      spec.update(shape: 'rectangle')
    end
  end

  class WorkSpec < ActiveRecord::Base
  end
end
