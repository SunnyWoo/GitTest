class ExportProductCodeService
  ROW_NAMES = %w(存货编码 存货名称 存货大类编码 计量单位组编码 主计量单位编码 启用日期 是否内销 是否采购).freeze
  SHEET_NAMES = %w(控制 成本 计划 批次属性 质量 其它 自定义 自由项 物料自由项档案 核算自由项档案).freeze
  YONGYOU_ENABLE_TIME = '2016-1-1'
  ROW_TYPE = %i(string string string string string string string string).freeze

  attr_reader :works, :standardized_works, :products

  def self.export_all
    new('all', nil, nil).export
  end

  def self.export_by_time(created_at_gteq, created_at_lteq)
    new('time', created_at_gteq, created_at_lteq).export
  end

  def initialize(export_type, created_at_gteq, created_at_lteq)
    if export_type == 'all'
      product_includes = [:craft, :spec, :product_material, :translations, category: :category_code]
      @works = Work.includes(:work_code, product: product_includes).where(user_type: 'Designer')
      @standardized_works = StandardizedWork.includes(:work_code, product: product_includes).where(user_type: 'Designer')
      @products = ProductModel.includes(product_includes).all
    else
      @works = Work.includes(:work_code, product: product_includes).where(user_type: 'Designer')
               .where('created_at >= ? And created_at <= ?', created_at_gteq, created_at_lteq)
      @standardized_works = StandardizedWork.includes(:work_code, product: product_includes).where(user_type: 'Designer')
                            .where('created_at >= ? And created_at <= ?', created_at_gteq, created_at_lteq)
      @products = ProductModel.includes(product_includes).where('created_at >= ? And created_at <= ?', created_at_gteq, created_at_lteq)
    end
  end

  def export
    Axlsx::Package.new do |excel|
      excel.workbook.add_worksheet(name: 'Sheet1') do |sheet|
        sheet.add_row ROW_NAMES
        work_product_code(sheet)
        standardized_work_product_code(sheet)
        customize_product_code(sheet)
        channel_product_code(sheet)
        deliver_order_product_code(sheet)
      end
      SHEET_NAMES.each do |sheet_name|
        excel.workbook.add_worksheet(name: sheet_name) # 这些sheet可以为空 但是必须存在
      end
      excel.use_shared_strings = true
      excel.serialize(file_name)
    end
    excel_content(file_name)
  end

  private

  # 设计师设计的商品编码
  def work_product_code(sheet)
    works.find_each.each do |work|
      sheet.add_row [work.product_code,
                     work.name,
                     "1#{work.product.product_cmsc_code}", # 用友商品大类的编码是以 1+product#product_cmsc_code
                     '01'.to_s, # 计量单位组编码
                     '0102'.to_s, # 主计量单位编码
                     enable_time(work.created_at),
                     '1', # 是否内销: 是
                     '1' # 是否采购: 是
                    ],
                    types: ROW_TYPE
    end
  end

  # 设计师设计的商品编码
  def standardized_work_product_code(sheet)
    standardized_works.find_each.each do |standardized_work|
      sheet.add_row [standardized_work.product_code, standardized_work.name,
                     "1#{standardized_work.product.product_cmsc_code}",
                     '01', '0102', enable_time(standardized_work.created_at), '1', '1'],
                    types: ROW_TYPE
    end
  end

  # 客制化商品编码
  def customize_product_code(sheet)
    products.each do |product|
      sheet.add_row ["#{product.product_code}-0000-000", "客制化-#{product.name}", "1#{product.product_cmsc_code}",
                     '01', '0102', YONGYOU_ENABLE_TIME, '1', '1'],
                    types: ROW_TYPE
    end
  end

  # 渠道销售的商品编码， ex: 淘宝, 天猫
  def channel_product_code(sheet)
    products.each do |product|
      sheet.add_row ["#{product.product_code}-0000-001", "渠道销售-#{product.name}", "1#{product.product_cmsc_code}",
                     '01', '0102', YONGYOU_ENABLE_TIME, '1', '1'],
                    types: ROW_TYPE
    end
  end

  # 抛单商品的商品编码
  def deliver_order_product_code(sheet)
    products.each do |product|
      sheet.add_row ["#{product.product_code}-0001-000", "抛单-#{product.name}", "1#{product.product_cmsc_code}",
                     '01', '0102', YONGYOU_ENABLE_TIME, '1', '1'],
                    types: ROW_TYPE
    end
  end

  def excel_content(file_name)
    excel_content = ''
    File.open(file_name, 'r') do |f|
      excel_content = f.read
    end
    File.delete(file_name)
    excel_content
  end

  def file_name
    @file_name or begin
      dir = "#{Rails.root}/tmp/excel/"
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      @file_name = "#{dir}product-code-#{Time.zone.now}.xlsx"
    end
  end

  def enable_time(work_created_time)
    work_created_time < YONGYOU_ENABLE_TIME ? YONGYOU_ENABLE_TIME : work_created_time.strftime('%Y-%m-%d')
  end
end
