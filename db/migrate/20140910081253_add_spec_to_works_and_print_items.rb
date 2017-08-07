class AddSpecToWorksAndPrintItems < ActiveRecord::Migration
  def change
    add_reference :works, :spec, index: true
    add_reference :print_items, :spec, index: true

    [Work, PrintItem].each do |clazz|
      clazz.find_each do |item|
        specs = WorkSpec.where(model_id: item.model_id)
        item.update(spec_id: specs.first.id)
      end
    end
  end

  class ProductModel < ActiveRecord::Base
  end

  class WorkSpec < ActiveRecord::Base
  end

  class Work < ActiveRecord::Base
  end

  class PrintItem < ActiveRecord::Base
  end
end
