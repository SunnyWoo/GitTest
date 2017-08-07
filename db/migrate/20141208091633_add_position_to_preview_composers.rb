class AddPositionToPreviewComposers < ActiveRecord::Migration
  def change
    add_column :preview_composers, :position, :integer

    PreviewComposer.find_each do |composer|
      composer.insert_at(1)
    end
  end

  class PreviewComposer < ActiveRecord::Base
    acts_as_list scope: :spec
  end
end
