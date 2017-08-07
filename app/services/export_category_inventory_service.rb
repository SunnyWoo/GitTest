class ExportCategoryInventoryService
  INVENTORY_CATEGORY_CODE_SIZE = 7
  ROW_NAMES = %w(存货大类编码 存货大类名称 对应条形码编码 录入日期 录入员).freeze
  ROW_TYPE = %i(string string string string string).freeze

  def self.export
    new.export
  end

  def initialize
    @categories = Set.new
    @materials = Set.new
    @crafts = Set.new
    @specs = Set.new
  end

  # excel: temp/excel/category_inventory-time.xlsx
  def export
    generate_category_inventories

    Axlsx::Package.new do |excel|
      excel.workbook.add_worksheet(name: 'Sheet1') do |sheet|
        sheet.add_row ROW_NAMES
        write_category_inventories(sheet)
      end
      excel.use_shared_strings = true
      excel.serialize(file_name)
    end
  end

  private

  def generate_category_inventories
    category_inventories = []
    ProductModel
      .includes(:craft, :spec, :product_material, :translations, category: [:category_code, :translations])
      .all.find_each do |product_model|
      product_cmsc_code = product_model.product_cmsc_code
      next unless product_cmsc_code.size == INVENTORY_CATEGORY_CODE_SIZE
      category_inventories << CategoryInventory.new(product_model)
    end

    category_inventories.each do |category_inventory|
      @categories << category_inventory.category
      @materials << category_inventory.material
      @crafts << category_inventory.craft
      @specs << category_inventory.spec
    end
  end

  def write_category_inventories(sheet)
    @categories.each { |category| sheet.add_row [category.code, category.name, '', '', '',], types: ROW_TYPE }
    @materials.each { |material| sheet.add_row [material.code, material.name, '', '', '',], types: ROW_TYPE }
    @crafts.each { |craft| sheet.add_row [craft.code, craft.name, '', '', '',], types: ROW_TYPE }
    @specs.each { |spec| sheet.add_row [spec.code, spec.name, '', '', '',], types: ROW_TYPE }
  end

  def file_name
    @file_name or begin
      dir = "#{Rails.root}/tmp/excel"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      @file_name = "#{dir}/category_inventory-#{Time.zone.now.to_i}.xlsx"
    end
  end

  class CategoryInventory
    attr_reader :product
    delegate :category, :product_material, :craft, :spec, to: :product, prefix: true
    delegate :product_material, to: :product

    def initialize(product)
      @product = product
    end

    def category
      @category ||= OpenStruct.new(code: "1#{product_category.code}", name: product_category.description)
    end

    def material
      @material ||= OpenStruct.new(code: "#{category.code}#{product_material.code}", name: product_material.description)
    end

    def craft
      @craft ||= OpenStruct.new(code: "#{material.code}#{product_craft.code}", name: product_craft.description)
    end

    def spec
      OpenStruct.new(code: "#{craft.code}#{product_spec.code}", name: product_spec.description)
    end
  end
end
