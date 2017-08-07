class AddModelIdToWorksAndPrintItems < ActiveRecord::Migration
  def up
    add_column :works, :model_id, :integer
    add_column :print_items, :model_id, :integer

    add_index :works, :model_id
    add_index :print_items, :model_id

    Work.find_each do |work|
      model = ProductModel.find_by(name: work.model)
      work.update(model_id: model.id)
    end

    PrintItem.find_each do |print_item|
      model = ProductModel.find_by(name: print_item.model)
      print_item.update(model_id: model.id)
    end

    remove_column :works, :model
    remove_column :print_items, :model
  end

  def down
    add_column :works, :model, :string
    add_column :print_items, :model, :string

    Work.find_each do |work|
      model = ProductModel.find_by(id: work.model_id)
      work.update(model: model.name)
    end

    PrintItem.find_each do |print_item|
      model = ProductModel.find_by(id: print_item.model_id)
      print_item.update(model: model.name)
    end

    remove_index :works, :model_id
    remove_index :print_items, :model_id

    remove_column :works, :model_id, :integer
    remove_column :print_items, :model_id, :integer
  end

  class ProductModel < ActiveRecord::Base
  end

  class Work < ActiveRecord::Base
  end

  class PrintItem < ActiveRecord::Base
  end
end
