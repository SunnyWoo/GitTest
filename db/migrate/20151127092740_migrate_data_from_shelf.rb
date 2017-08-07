class MigrateDataFromShelf < ActiveRecord::Migration
  def change
    add_column :shelves, :material_id, :integer
    add_index :shelves, :material_id

    add_column :shelves, :category_id, :integer
    add_index :shelves, :category_id

    Shelf.find_each do |shelf|
      migrate_data_to_material(shelf)
      migrate_data_to_category(shelf)
    end
  end

  class Shelf < ActiveRecord::Base
  end

  class ShelfMaterial < ActiveRecord::Base
  end

  class ShelfCategory < ActiveRecord::Base
  end

  def migrate_data_to_material(shelf)
    material = ShelfMaterial.find_by(serial: shelf.section, factory_id: shelf.factory_id)
    if material
      update_material_quantity_by_shelf_name(shelf, material)
      shelf.update(material_id: material.id)
    else
      # 商品编号为'0'代表空的货架
      if shelf.section != '0'
        new_material = ShelfMaterial.create(factory_id: shelf.factory_id,
                                            name: shelf.name,
                                            serial: shelf.section,
                                            safe_minimum_quantity: shelf.safe_minimum_quantity)
        update_material_quantity_by_shelf_name(shelf, new_material)
        shelf.update(material_id: new_material.id)
      end
    end
  end

  def migrate_data_to_category(shelf)
    return unless shelf.serial_name
    category = ShelfCategory.find_by(name: shelf.serial_name, factory_id: shelf.factory_id)
    if category
      shelf.update_attribute(:category_id, category.id)
    else
      new_category = ShelfCategory.create(factory_id: shelf.factory_id, name: shelf.serial_name)
      shelf.update_attribute(:category_id, new_category.id)
    end
  end

  def update_material_quantity_by_shelf_name(shelf, material)
    if shelf.serial_name == '报废'
      material.increment!(:scrapped_quantity, shelf.quantity.to_i)
    else
      material.increment!(:quantity, shelf.quantity.to_i)
    end
  end
end
