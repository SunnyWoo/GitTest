namespace :order do
  task reconciliation: :environment do
    Order.reconciliation
  end

  task auto_cancel: :environment do
    OrderAutoCancelService.new.execute
  end

  #
  # shipping to TW
  # 訂單付款 24小時後 自動開立發票
  #
  task shipping_to_tw_create_invoice: :environment do
    key = 'execute:order:shipping_to_tw_create_invoice'
    if $redis.get(key).nil?
      $redis.set(key, 1)
      InvoiceService.shipping_to_tw_create_invoice
      $redis.del(key)
    end
  end

  #
  # Order.invoice_ready_upload
  #
  task invoice_ready_upload_create_invoice: :environment do
    key = 'execute:order:invoice_ready_upload_create_invoice'
    if $redis.get(key).nil?
      $redis.set(key, 1)
      InvoiceService.invoice_ready_upload_create_invoice
      $redis.del(key)
    end
  end

  # task info: https://app.asana.com/0/36098473060746/98251841224297
  # maintainer: Manic
  # 這個 task 是拿來在 production server import taobao 用的
  # 到時運營會提供需要的 taobao.csv，請放在可以執行的位置，
  # 並修改 spec/fixtures/taobao_template.csv 到指定的位置。
  task :import_taobao do
    serv = TaobaoImportService.new
    order_params = serv.parse_csv_to_order_params('spec/fixtures/taobao_template.csv')
    serv.generate_orders(order_params)
  end

  # task info: https://app.asana.com/0/42686877023074/103505738637619
  # 这个task是拿来导出台湾站的所有抛单的订单编号
  # 会导出文件: delivered_order_no.csv
  task export_delivered_order_no: :environment do
    File.open('delivered_order_no.csv', 'w') do |file|
      file.write(
        CSV.generate do |csv|
          Order.where.not(delivered_at: nil).find_each do |order|
            csv << [order.id, order.order_no]
          end
        end
      )
    end
  end

  # task info: https://app.asana.com/0/42686877023074/103505738637619
  # 这个task是拿来导入台湾站的所有抛单的订单编号到中国站
  # 需要的文件: delivered_order_no.csv
  task import_delivered_order_no: :environment do
    if File.exist?('delivered_order_no.csv')
      CSV.foreach('delivered_order_no.csv') do |row|
        next if row[0].blank?
        order = Order.find_by(remote_id: row[0])
        next if order.blank?
        remote_info ||= {}
        remote_info[:order_no] = row[1]
        order.update_column(:remote_info, remote_info)
      end
    else
      puts 'need delivered_order_no.csv'
    end
  end

  # 更新上月初到本月的所有抛单的remote_info: single_item
  task update_remote_info_single_item: :environment do
    DeliverOrder::BaseService.new.get('orders/single_item_infos') do |res|
      res['orders'].each do |order_info|
        order = Order.find_by(remote_id: order_info['order_id'])
        next unless order
        order.remote_info['single_item'] = order_info['single_item']
        order.save
      end
    end
  end
end
