class Print::StorageForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :factory_id,
                :shelf_serial,
                :material_serial,
                :quantity,
                :message,
                :shelf_name,
                :material_name,
                :move_from,
                :move_target,
                :storage

  validates :shelf_serial, presence: true
  validates :material_serial, presence: true

  def stock
    after_valid_attr do
      find_or_initialize_storage
      @storage.stock!(quantity.to_i)
    end
  end

  def restore
    after_valid_attr do
      find_storage!
      @storage.restore!(quantity.to_i)
    end
  end

  def ship_or_allocate
    after_valid_attr do
      find_storage!
      @storage.ship!(quantity.to_i)
    end
  end

  def move
    compare_each_material_quantity!
    fetch_move_from_shelves
    fetch_move_target_shelves
    ActiveRecord::Base.transaction do
      move_from.each do |_key, value|
        value[:from_storage].move_out!(value[:quantity].to_i)
      end
      move_target.each do |_key, value|
        value[:target_storage].move_in!(value[:quantity].to_i)
      end
    end
  end

  private

  def shelf
    @shelf = Shelf.find_by!(factory_id: factory_id, serial: shelf_serial)
  end

  def material
    @material = ShelfMaterial.find_by!(factory_id: factory_id, serial: material_serial)
  end

  # TODO: 将货架存储和货架拆成两个model 方便货架跟物料建立起多对多关系
  def find_or_initialize_storage
    if storage_exist?
      find_storage
    else
      @storage = new_storage
    end
  end

  def find_storage
    @storage ||= Shelf.find_by(factory_id: factory_id, serial: shelf_serial, material: material)
  end

  def find_storage!
    @storage ||= Shelf.find_by!(factory_id: factory_id, serial: shelf_serial, material: material)
  end

  def fetch_move_from_shelves
    move_from.each do |key, attr_value|
      from_shelf = Shelf.ransack(factory_id_eq: factory_id,
                                serial_eq: attr_value[:shelf_serial],
                                material_serial_eq: attr_value[:material_serial]).result.first
      fail RecordNotFoundError unless from_shelf
      move_from[key].merge!(from_storage: from_shelf)
    end
  end

  def fetch_move_target_shelves
    move_target.each.each do |key, attr_value|
      target_shelf = Shelf.ransack(factory_id_eq: factory_id,
                                  serial_eq: attr_value[:shelf_serial],
                                  material_serial_eq: attr_value[:material_serial]).result.first

      new_target = create_target_shelf(attr_value) unless target_shelf
      move_target[key].merge!(target_storage: target_shelf || new_target)
    end
  end

  def create_target_shelf(options)
    self.shelf_serial = options[:shelf_serial]
    self.material_serial = options[:material_serial]
    new_storage
  end

  def compare_each_material_quantity!
    fail ArgumentError, 'from material not equal target material' if each_material_quantity_of_from != each_material_quantity_of_target
  end

  def each_material_quantity_of_from
    move_from.values.each_with_object({}) do |value, hash|
      hash[value[:material_serial].to_sym] ||= 0
      hash[value[:material_serial].to_sym] += value[:quantity].to_i
    end
  end

  def each_material_quantity_of_target
    move_target.values.each_with_object({}) do |value, hash|
      hash[value[:material_serial].to_sym] ||= 0
      hash[value[:material_serial].to_sym] += value[:quantity].to_i
    end
  end

  def storage_exist?
    find_storage.present?
  end

  def new_storage
    return Shelf.create(factory_id: shelf.factory_id,
                        serial: shelf.serial,
                        category_id: shelf.category_id,
                        material_id: material.id) if shelf.material
    shelf.update(material: material) # 这种情况表示这是一个没有放物料的货架
    shelf
  end

  def after_valid_attr
    if valid?
      yield
    else
      fail ActiveRecord::RecordInvalid, self
    end
  end
end
