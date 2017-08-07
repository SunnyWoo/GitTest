class ChangePreviewComposersBelongsToSpec < ActiveRecord::Migration
  def up
    rename_column :preview_composers, :model_id, :spec_id

    PreviewComposer.find_each do |pc|
      spec = WorkSpec.find_by(model_id: pc.spec_id)
      pc.update(spec_id: spec.id)
    end
  end

  class WorkSpec < ActiveRecord::Base
  end

  class PreviewComposer < ActiveRecord::Base
  end

  PreviewComposer.inheritance_column = :whatever
end
