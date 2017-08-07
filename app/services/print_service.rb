class PrintService
  extend PrintHelper

  # 熱轉印简易列表.csv
  def self.export_sublimate_csv(print_items)
    column_titles = %w(訂單編號 列印編號 產品類型 出貨方式 折扣码 发票)
    CSV.generate do |csv|
      csv << column_titles
      print_items.each do |print_item|
        order = print_item.order_item.order
        coupon_info = order.coupon.present? ? "#{order.coupon.title} - #{order.coupon.code}" : ''
        shipping_way = render_shipping_way(order.shipping_info.shipping_way)
        csv << [order.order_no, print_item.timestamp_no, print_item.product_name, shipping_way,
                coupon_info, order.rate_type_name]
      end
    end
  end

  # 倉儲貨架.csv
  def self.export_shelves_csv(shelves)
    column_titles = %i(serial category_name material_serial material_name quantity safe_minimum_quantity)
    human_column_titles = column_titles.map { |column| Shelf.human_attribute_name(column) }
    CSV.generate do |csv|
      csv << human_column_titles
      shelves.each do |shelf|
        csv << [shelf.serial, shelf.category_name, shelf.material_serial, shelf.material_name,
                shelf.quantity, shelf.material_safe_minimum_quantity]
      end
    end
  end

  # 倉儲貨架紀錄.csv
  def self.export_shelf_activities_csv(activities)
    column_titles = %i(serial category_name material_serial material_name quantity safe_minimum_quantity)
    human_column_titles = column_titles.map { |column| Shelf.human_attribute_name(column) }
    human_column_titles += %w(操作者 行為 備註)
    CSV.generate do |csv|
      csv << human_column_titles
      activities.each do |activity|
        shelf = activity.trackable
        csv << [shelf.serial, shelf.category_name, shelf.material_serial, shelf.material_name,
                shelf.quantity, shelf.material_safe_minimum_quantity, activity.user.username,
                "#{Shelf.human_attribute_name("actions.#{activity.key}")} #{activity.extra_info['quantity']}",
                activity.message]
      end
    end
  end

  # 遲到歷史記錄.csv
  def self.export_delayed_history_csv(print_items)
    locale = Region.china? ? :'zh-CN' : :'zh-TW'
    column_titles = %w(訂單編號 商品編號 列印編號 列印類型 重印類別 產品分類 產品類型
                       訂單審核通過時間 進入印刷工作站時間 進入熱轉印工作站時間 商品生產完成時間
                       累計處理時間)
    CSV.generate do |csv|
      csv << column_titles
      print_items.each do |print_item|
        order_item = print_item.order_item
        order = order_item.order
        product = order_item.itemable.product
        category = product.category
        print_type = print_item.is_reprint? ? '重印' : '原始訂單'
        target_time = print_item.sublimated_at || Time.zone.now
        csv << [order.order_no, order_item.itemable.product_code, print_item.timestamp_no,
                print_type, print_item.print_histories.last.try(:reprint_type_text),
                category.name(locale), product.name(locale), print_item.created_at,
                print_item.prepare_at, print_item.print_at, print_item.sublimated_at,
                render_hours_from_target_time(print_item.prepare_at, target_time: target_time)]
      end
    end
  end

  # 倉儲物料.csv
  def self.export_shelf_materials_csv(materials)
    column_titles = %i(serial name quantity safe_minimum_quantity scrapped_quantity)
    human_column_titles = column_titles.map { |column| ShelfMaterial.human_attribute_name(column) }
    CSV.generate do |csv|
      csv << human_column_titles
      materials.each do |shelf|
        csv << [shelf.serial, shelf.name, shelf.quantity, shelf.safe_minimum_quantity, shelf.scrapped_quantity]
      end
    end
  end

  # 倉儲物料紀錄.csv
  def self.export_shelf_materials_activities_csv(activities)
    column_titles = %i(serial name quantity safe_minimum_quantity scrapped_quantity)
    human_column_titles = column_titles.map { |column| ShelfMaterial.human_attribute_name(column) }
    human_column_titles += %w(操作者 行為 備註 行為数量)
    CSV.generate do |csv|
      csv << human_column_titles
      activities.each do |activity|
        material = activity.trackable
        csv << [material.serial, material.name, material.quantity, material.safe_minimum_quantity,
                material.scrapped_quantity, activity.user.username,
                "#{ShelfMaterial.human_attribute_name("actions.#{activity.key}")}",
                activity.extra_info['quantity'],
                activity.message]
      end
    end
  end

  # 重印歷史記錄.csv
  def self.export_reprint_history_csv(reprint_items)
    locale = Region.china? ? :'zh-CN' : :'zh-TW'
    column_titles = %w(重印時間 訂單編號 商品編號 列印編號 產品分類 產品類型 操作人員帳號
                       重印類別 原因說明)
    CSV.generate do |csv|
      csv << column_titles
      reprint_items.each do |reprint_item|
        print_item = reprint_item.print_item
        order_item = print_item.order_item
        order = order_item.order
        product = order_item.itemable.product
        category = product.category
        csv << [reprint_item.prepare_at, order.order_no, order_item.itemable.product_code,
                reprint_item.timestamp_no, category.name(locale), product.name(locale),
                reprint_item.create_log.try(:user).try(:email), reprint_item.reprint_type_text, reprint_item.reason]
      end
    end
  end
end
