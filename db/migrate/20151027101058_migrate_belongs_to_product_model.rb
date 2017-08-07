class MigrateBelongsToProductModel < ActiveRecord::Migration
  def change
    rename_column :impositions, :spec_id, :model_id
    rename_column :preview_composers, :spec_id, :model_id
    remove_column :works, :spec_id
    rename_column :archived_works, :spec_id, :model_id
    rename_column :work_templates, :work_spec_id, :model_id
    rename_column :delivery_orders, :spec_id, :model_id
    remove_column :print_items, :spec_id
    rename_column :work_sets, :spec_id, :model_id

    Imposition.find_each do |imposition|
      next unless imposition.model_id
      spec = WorkSpec.find(imposition.model_id)
      next unless spec.model
      imposition.update(model_id: spec.model.id)
    end

    PreviewComposer.find_each do |composer|
      next unless composer.model_id
      spec = WorkSpec.find(composer.model_id)
      next unless spec.model
      composer.update(model_id: spec.model.id)
    end

    ArchivedWork.find_each do |work|
      next unless work.model_id
      spec = WorkSpec.find(work.model_id)
      next unless spec.model
      work.update(model_id: spec.model.id)
    end

    WorkTemplate.find_each do |template|
      next unless template.model_id
      spec = WorkSpec.find(template.model_id)
      next unless spec.model
      template.update(model_id: spec.model.id)
    end

    DeliveryOrder.find_each do |delivery_order|
      next unless delivery_order.model_id
      spec = WorkSpec.find(delivery_order.model_id)
      next unless spec.model
      delivery_order.update(model_id: spec.model.id)
    end

    WorkSet.find_each do |work_set|
      next unless work_set.model_id
      spec = WorkSpec.find(work_set.model_id)
      next unless spec.model
      work_set.update(model_id: spec.model.id)
    end
  end

  class ProductModel < ActiveRecord::Base
  end

  class WorkSpec < ActiveRecord::Base
    belongs_to :model, class_name: 'ProductModel'
  end

  class Imposition < ActiveRecord::Base
  end
  Imposition.inheritance_column = :whatever

  class PreviewComposer < ActiveRecord::Base
  end
  PreviewComposer.inheritance_column = :whatever

  class Work < ActiveRecord::Base
  end

  class ArchivedWork < ActiveRecord::Base
  end

  class WorkTemplate < ActiveRecord::Base
  end

  class DeliveryOrder < ActiveRecord::Base
  end

  class WorkSet < ActiveRecord::Base
  end
end
