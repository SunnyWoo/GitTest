require 'net/ftp'
# Order Payment 藍新&貨到付款 , 才需開立電子發票
module InvoiceService
  extend ActiveSupport::Concern

  #
  # 上傳檔案給金財通的檔案
  # 有主檔(訂單) 加上明細檔(訂單資訊)
  #
  def self.data_to_bankpro(orders)
    # 整理表每筆訂單匯出的資料
    InvoiceService.logcraft(:get_row, "order_ids:#{orders.map(&:id).join(',')}")
    rows = []
    count = 0
    orders.each do |order|
      next if !order.is_need_create_invoice?
      rows << order.invoice_info['order_row']
      order_item_rows = order.invoice_info['order_item_rows']
      rows.concat(order_item_rows) if order_item_rows.size > 0
      order.invoice_uploading!
      count += 1
    end
    file_name = InvoiceService.export_to_file(rows, count)
    InvoiceService.upload_to_ftp(file_name)
  end

  #
  # 寫入訂單檔
  # 檔名:統編-O-yyyymmdd-hhmmss.txt
  #
  def self.export_to_file(rows, order_size)
    return nil if rows.size == 0

    file_name = "#{Settings.commandp_tax_id}-O-#{Time.now.strftime("%Y%m%d-%H%M%S")}.txt"
    f = File.new(file_name, 'w')
    rows.each do |row|
      f.write("#{row.values.join("|")}\015\012")
    end
    f.write("#{order_size}\015\012")
    f.close
    InvoiceService.logcraft(:export_file, "file_name:#{file_name}")
    file_name
  end

  #
  # Upload to 金財通FTP
  #
  def self.upload_to_ftp(file_name)
    InvoiceService.logcraft(:upload_to_ftp, "file_name:#{file_name}")
    ftp = FtpService.new( url: Settings.bpscm.url,
                          port: Settings.bpscm.port,
                          username: Settings.bpscm.username,
                          password: Settings.bpscm.password)
    begin
      ftp.login
      ftp.chdir("Upload")
      ftp.upload_file(file_name)
      ftp.close
      InvoiceService.logcraft(:upload_to_ftp_finish, "file_name:#{file_name}")
      true
    rescue => e
      InvoiceService.logcraft(:upload_to_ftp_error, "file_name:#{file_name}\nErrorMsg:#{e}")
      false
    end
  end

  #
  # 下載金財通檔案
  #
  def self.download_bankpro_file
    InvoiceService.logcraft(:download_bankpro_file)
    # 連線到FTP
    ftp = Net::FTP.new(Settings.bpscm.url)
    begin
      ftp.passive = true
      ftp.connect(Settings.bpscm.url, Settings.bpscm.port)
      ftp.login(Settings.bpscm.username, Settings.bpscm.password)
      ftp.chdir 'Download'
    rescue e
      InvoiceService.logcraft(:login_ftp_error, e)
    end

    # 下載檔案
    # 將檔案 mv 到 DownloadBackup
    list = ftp.list
    files = []
    list.each do |file|
      filename = file.split.last
      files << filename
      ftp.getbinaryfile(filename, filename)
      InvoiceService.logcraft(:download_file, "Filename:#{filename}")
      path = ftp.pwd
      newpath = path.gsub(/Download/, 'DownloadBackup')
      ftp.rename(filename,"#{newpath}/#{filename}")
      InvoiceService.logcraft(:move_ftp_file_to_backup, "Filename:#{filename} Move to #{newpath}/#{filename}")
    end
    ftp.close

    if files.size > 0
      # 若同時有 訂單回覆檔 和 發票狀態檔 sort
      # 先讀 訂單回覆檔 再 讀 發票狀態檔
      files.sort!{ |x,y| y <=> x }.each do |filename|
        puts filename
        if filename.match('InvStatus')
          InvoiceService.check_inv_status_file(filename)
        else
          InvoiceService.check_reply_file(filename)
        end
      end
    end
    InvoiceService.logcraft(:download_bankpro_file_finish)
  end

  #
  # 檢查下載回來的訂單回覆檔
  #
  def self.check_reply_file(filename)
    text = File.open(filename).read
    text.gsub!(/\r\n?/, "\n")
    InvoiceService.logcraft(:read_file, "Filename:#{filename}\nContent:\n#{text}")
    text.each_line do |line|
      list = line.split('|')
      order_no, status, error_msg = list
      if order_no.present? && order = Order.find_by(order_no: order_no)
        if status.present?
          order.invoice_uploaded! if order.invoice_uploading?
        else
          order.invoice_upload_error! if order.invoice_uploading?
          order.update!(invoice_memo: line)
        end
        InvoiceService.logcraft(:update_order, "OrderNo:#{order.order_no}\nBankPro Reply Msg:#{line}", order_id: order.id)
      end
    end
  end

  #
  # 檢查下載回來的發票狀態檔
  #
  def self.check_inv_status_file(filename)
    text = File.open(filename).read
    text.gsub!(/\r\n?/, "\n")
    InvoiceService.logcraft(:read_file, "Filename:#{filename}\nContent:\n#{text}")
    text.each_line do |line|
      list = line.split('|')
      order_no = list.first
      invoice_number = list[3]
      if order_no.present?
        order = Order.find_by(order_no: order_no)
        if order
          InvoiceService.logcraft(:update_order, "OrderNo:#{order.order_no}\nInvoiceNumber:#{invoice_number}\n", order_id: order.id)
          order.update!(invoice_number: invoice_number, invoice_number_created_at: Time.zone.today.to_s)
          order.create_activity(:update_invoice,
                                invoice_number: invoice_number,
                                invoice_memo: line,
                                source: {channel: 'invoice'})
          order.invoice_finish! if order.invoice_uploaded?
        end
      end
    end
  end

  #
  # 再次檢查要上傳的資訊
  #
  def self.check_upload_data(orders)
    status = false
    messages =[]
    orders.each do |order|
      messages << "OrderID:#{order.id} 缺少發票資訊" if order.invoice_info.nil?
    end
    status = true if messages.size == 0
    return { status: status, messages: messages }
  end

  def self.logcraft(key, message = nil, extra_info = {})
    Logcraft::Activity.create(
        trackable_type: 'InvoiceService',
        source: {channel: 'invoice'},
        key: key,
        message: message,
        extra_info: extra_info
      )
  end

  #
  # shipping to TW
  # 訂單付款 24小時後 自動開立發票
  #
  def self.shipping_to_tw_create_invoice
    orders = Order.ransack(shipping_info_country_code_eq:'TW').result.should_invoices.
                   invoice_not_upload.before(1.day.ago)
    create_invoice(orders)
  end

  #
  # Order.invoice_ready_upload
  #
  def self.invoice_ready_upload_create_invoice
    orders = Order.invoice_ready_upload
    create_invoice(orders)
  end

  #
  # 更新 Order Invoice Info
  #
  def update_invoice_info(order_status = nil)
    return if Region.china?
    order_status ||= invoice_status(self)
    update!(invoice_info: {
      order_row: get_order_row(order_status),
      order_item_rows: get_order_item_rows(self)
    })
  end

  #
  # Order 是否需要開立發票
  # 大陸地區不開立發票
  def is_need_create_invoice?
    !(Region.china?) && payment != 'redeem'
  end

  #稅率別 1:應稅 2:零稅率 3:免稅 *
  # shipping info country code
  # TW = 1
  # Other Country Code = 2
  def rate_type
    shipping_info_country_code == 'TW' ? 1 : 2
  end

  def rate_type_name
    rate_type == 1 ? '應稅' : '零稅率'
  end

  private

  #
  # 訂單開立發票
  #
  def self.create_invoice(orders)
    return if orders.nil? || orders.size == 0
    orders.each(&:update_invoice_info)
    res =  check_upload_data(orders)
    return data_to_bankpro(orders) if res[:status]
    emails = SiteSetting.by_key('InvoiceErrorReceiver') || 'rich.ke@commandp.com'
    ApplicationMailer.notice_admin(emails, '自動開立發票上傳錯誤', res[:messages].join(',')).deliver
    logcraft(:neweb_create_invoice_check_error, res[:message])
  end

  #
  # 0:新增 1:修單(指部分退貨) 2:刪除(指全退) *
  #
  def invoice_status(order)
    return 0 if order.invoice_number.nil?
    case order.aasm_state
    when 'part_refunded'
      1
    when 'refunded'
      2
    else
      0
    end
  end

  # 國外訂單的發票 Mail 使用 finance@commandp.com
  def invoice_email
    if shipping_info_country_code != 'TW'
      'finance@commandp.com'
    else
      billing_info_email
    end
  end

  def order_price
    price_after_refund('TWD')
  end

  def order_mome
    memo = "收件人：#{shipping_info.name} 運送國家：#{shipping_info.country_code}"
    memo += " 物流單號：#{ship_code}" if rate_type == 2
    memo
  end
  #
  # 要上傳的主檔格式
  # order_status 0:新增 1:修單(指部分退貨) 2:刪除(指全退) *
  def get_order_row(order_status = 0)
    order = self
    # 主檔, 有 * 為必填
    row = {
      r01: 'M', #主檔代號 *
      r02: order.order_no, #訂單編號 *
      r03: order_status, #訂單狀態 0:新增 1:修單(指部分退貨) 2:刪除(指全退) *
      r04: order.created_at.strftime("%Y/%m/%d"), #訂單日期 *
      r05: order.created_at.strftime("%Y/%m/%d"), #預計出貨 *
      r06: rate_type, #稅率別 1:應稅 2:零稅率 3:免稅 *
      r07: nil, #訂單金額(未稅)
      r08: nil, #訂單稅額
      r09: order_price, #訂單金額(含稅) *
      r10: Settings.commandp_tax_id, #賣方統一編號 *
      r11: nil, #賣方廠編
      r12: nil, #買方統一編號
      r13: nil, #買受人公司名稱
      r14: order.user_id || order.order_no, #會員編號 *
      r15: order.billing_info_name, #會員姓名 *
      r16: nil, #會員郵遞區號
      r17: nil, #會員地址 *
      r18: nil, #會員電話
      r19: nil, #會員行動電話
      r20: invoice_email, #會員電子郵件 *
      r21: 0, #紅利點數折扣金額
      r22: 'n', #索取紙本發票 Y:紙本 N:非紙本(指電子發票) *
      r23: nil, #發票捐贈註記
      r24: order_mome, #訂單註記
      r25: order.payment, #付款方式
      r26: order.ship_code, #相關號碼 1(出貨單號) 出貨單號顯示在紙本發票列印樣式右邊
      r27: nil, #相關號碼 2
      r28: nil, #相關號碼 3 若有「強制退款」請註記在此欄位
      r29: nil, #主檔備註
      r30: nil, #商品名稱
      r31: nil, #載具類別號碼
      r32: nil, #載具顯碼 id1(明碼)
      r33: nil, #載具隱碼 id2(內碼)
    }
    row
  end

  #
  # 明細檔, 有 * 為必填
  #
  def get_order_item_rows(order)
    tmp = []
    tmp_number = 0
    #order item
    order.order_items.each_with_index do |order_item, index|
      next if order_item.itemable.product.nil?
      tmp_number = index + 1
      row = {
        r01: 'D', #明細代號 固定填 D *
        r02: tmp_number , #序號 *
        r03: order.order_no, #訂單編號 *
        r04: order_item.id, #商品編號
        r05: nil, #商品條碼
        r06: order_item.itemable.product.name, #商品名稱 *
        r07: nil, #商品規格
        r08: nil, #單位
        r09: nil, #單價
        r10: order_item.quantity, #數量 *
        r11: nil, #未稅金額
        r12: order_item.selling_price['TWD'], #含稅金額 *
        r13: 0, #健康捐
        r14: 1, #稅率別 *
        r15: 0, #紅利點數折扣金額
        r16: nil, #明細備註
      }
      tmp << row
    end
    # coupon
    if order.coupon.present?
      discount = Price.new(order.discount, order.currency)['TWD'].ceil
      tmp_number += 1
      row = {
        r01: 'D', #明細代號 固定填 D *
        r02: tmp_number , #序號 *
        r03: order.order_no, #訂單編號 *
        r04: nil, #商品編號
        r05: nil, #商品條碼
        r06: '折扣', #商品名稱 *
        r07: nil, #商品規格
        r08: nil, #單位
        r09: nil, #單價
        r10: 1, #數量 *
        r11: nil, #未稅金額
        r12: - discount, #含稅金額 *
        r13: 0, #健康捐
        r14: 1, #稅率別 *
        r15: 0, #紅利點數折扣金額
        r16: "Coupon code:#{coupon.code}" #明細備註
      }
      tmp << row
    end
    # shipping fee
    shipping_fee = Price.new(order.shipping_fee, order.currency)['TWD'].ceil
    if shipping_fee > 0
      tmp_number += 1
      row = {
        r01: 'D', #明細代號 固定填 D *
        r02: tmp_number , #序號 *
        r03: order.order_no, #訂單編號 *
        r04: nil, #商品編號
        r05: nil, #商品條碼
        r06: '運費', #商品名稱 *
        r07: nil, #商品規格
        r08: nil, #單位
        r09: nil, #單價
        r10: 1, #數量 *
        r11: nil, #未稅金額
        r12: shipping_fee, #含稅金額 *
        r13: 0, #健康捐
        r14: 1, #稅率別 *
        r15: 0, #紅利點數折扣金額
        r16: order.shipping_info_shipping_way #明細備註
      }
      tmp << row
    end

    # shipping fee discount
    shipping_fee_discount = Price.new(order.shipping_fee_discount, order.currency)['TWD'].ceil
    if shipping_fee_discount > 0
      tmp_number += 1
      row = {
        r01: 'D', #明細代號 固定填 D *
        r02: tmp_number , #序號 *
        r03: order.order_no, #訂單編號 *
        r04: nil, #商品編號
        r05: nil, #商品條碼
        r06: '運費折扣', #商品名稱 *
        r07: nil, #商品規格
        r08: nil, #單位
        r09: nil, #單價
        r10: 1, #數量 *
        r11: nil, #未稅金額
        r12: - shipping_fee_discount, #含稅金額 *
        r13: 0, #健康捐
        r14: 1, #稅率別 *
        r15: 0, #紅利點數折扣金額
        r16: nil#明細備註
      }
      tmp << row
    end

    #refund
    order.refunds.each do |refund|
      refund_amount = Price.new(refund.amount, order.currency)['TWD'].ceil
      tmp_number += 1
      row = {
        r01: 'D', #明細代號 固定填 D *
        r02: tmp_number , #序號 *
        r03: order.order_no, #訂單編號 *
        r04: nil, #商品編號
        r05: nil, #商品條碼
        r06: '退款', #商品名稱 *
        r07: nil, #商品規格
        r08: nil, #單位
        r09: nil, #單價
        r10: 1, #數量 *
        r11: nil, #未稅金額
        r12: -refund_amount, #含稅金額 *
        r13: 0, #健康捐
        r14: 1, #稅率別 *
        r15: 0, #紅利點數折扣金額
        r16: nil #明細備註
      }
      tmp << row
    end
    tmp
  end
end
