class AddWorkTypeToPreviews < ActiveRecord::Migration
  def change
    add_column :previews, :work_type, :string

    Preview.update_all(work_type: 'Work')
  end

  class Preview < ActiveRecord::Base
  end
end
