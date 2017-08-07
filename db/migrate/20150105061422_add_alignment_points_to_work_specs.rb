class AddAlignmentPointsToWorkSpecs < ActiveRecord::Migration
  def change
    add_column :work_specs, :alignment_points, :string

    WorkSpec.find_each do |spec|
      spec.update(alignment_points: 'none')
    end
  end

  class WorkSpec < ActiveRecord::Base
  end
end
