class UploadInventoryService
  attr_accessor :inventory

  def initialize(inventory)
    @inventory = inventory
  end

  def upload
    inventory_type.new(inventory).upload
  end

  private

  def inventory_type
    "#{self.class.name}::#{inventory.class.name}Inventory".constantize
  end

  class WorkCodeInventory
    attr_accessor :work_code

    def initialize(work_code)
      @work_code = work_code
    end

    def upload
      return if not_need_upload?
      Yonyou::UploadInventoryWorker.perform_async(inventory_body)
    end

    private

    def inventory_body
      {
        inventory: {
          code: work_code.product_code,
          name: work_code.work.name,
          sort_code: "1#{work_code.work.product.product_cmsc_code}", # 用友分类规则 “1+product.product_cmsc_code”
          main_measure: '0102', # 用友单位编码 “个”
          entry: [
            {
              invcode: work_code.product_code
            }
          ]
        }
      }
    end

    def not_need_upload?
      !work_code.designer?
    end
  end

  class ProductModelInventory
    attr_accessor :product_model

    def initialize(product_model)
      @product_model = product_model
    end

    def upload
      product_inventory_codes = [
        { type: '客制化', code: "#{product_model.product_code}-0000-000" },
        { type: '渠道销售', code:  "#{product_model.product_code}-0000-001" },
        { type: '抛单', code: "#{product_model.product_code}-0001-000" }
      ]
      product_inventory_codes.each do |inventory|
        Yonyou::UploadInventoryWorker.perform_async(inventory_body(inventory[:code], inventory[:type]))
      end
    end

    private

    def inventory_body(inventory_code, inventory_type)
      {
        inventory: {
          code: inventory_code,
          name: "#{inventory_type}-#{product_model.name}",
          sort_code: "1#{product_model.product_cmsc_code}", # 用友分类规则 “1+product.product_cmsc_code”
          main_measure: '0102', # 用友单位编码 “个”
          entry: [
            {
              invcode: inventory_code
            }
          ]
        }
      }
    end
  end
end
