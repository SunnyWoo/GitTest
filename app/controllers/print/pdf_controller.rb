class Print::PdfController < PrintController
  skip_before_action :authenticate_factory_member!, only: [:b2b_sticker]
  require 'barby/barcode/code_128'
  require 'barby/outputter/png_outputter'
  layout 'pdf'

  def product_ticker
    authorize OrderItem, :product_ticker?
    @order_item = OrderItem.find(params[:order_item_id])
    @model = @order_item.itemable.product
    @order = @order_item.order
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @order_item.id.to_s,
               template: '/print/pdf/product_ticker.html.slim',
               page_height: '65mm', page_width: '90mm',
               layout: 'pdf.html.slim',
               margin: { top: 0, bottom: 3.5, left: 7.5, right: 7.5 }
      end
    end
  end

  def b2b_sticker
    @image_path = params[:image]
    @message = params[:message]
    @name = @message.delete('name')
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @name,
               template: '/print/pdf/b2b_sticker.html.slim',
               page_height: '65mm', page_width: '90mm',
               layout: 'pdf.html.slim',
               margin: { top: 0, bottom: 3.5, left: 7.5, right: 7.5 }
      end
    end
  end

  def delivery_note
    authorize Order, :delivery_note?
    @order = Order.find(params[:id])
    set_locale_in_delivery_note
    @order_items = @order.order_items
    header = { right: '[page] / [topage]' } if @order_items.count > 4
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @order.order_no,
               template: '/print/pdf/delivery_note.html.slim',
               page_size: 'A5',
               layout: 'pdf.html.slim',
               margin: { top: 10, bottom: 50, left: 10, right: 10 },
               header: header,
               footer: { content: render_to_string(template: '/print/pdf/delivery_note_footer.html.slim') }
      end
    end
  end

  def package_delivery_note
    authorize Package, :delivery_note?
    if params[:id].present?
      @orders = Order.where(id: params[:id])
      @order_items = OrderItem.unpackaged.where(order_id: params[:id])
    elsif params[:package][:print_items].present?
      print_item_ids = params[:package][:print_items].keys
      @orders = Order.ransack(print_items_id_in: print_item_ids).result.group('orders.id')
      @order_items = OrderItem.ransack(print_items_id_in: print_item_ids).result.group('order_items.id')
    elsif params[:package][:orders].present?
      @orders = Order.where(id: params[:package][:orders].keys)
      @order_items = OrderItem.joins(:order).merge(Order.where(id: params[:package][:orders].keys)).unpackaged
    else
      fail ParametersInvalidError
    end
    @order = @orders.first
    set_locale_in_delivery_note
    header = { right: '[page] / [topage]' } if @order_items.reload.size > 4
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @orders.pluck(:order_no).join(' '),
               template: '/print/pdf/package_delivery_note.html.slim',
               page_size: 'A5',
               layout: 'pdf.html.slim',
               margin: { top: 10, bottom: 50, left: 10, right: 10 },
               header: header,
               footer: { content: render_to_string(template: '/print/pdf/package_delivery_note_footer.html.slim') }
      end
    end
  end

  # 由于出货单背面都一样
  # 所以此处仅用来制作出货单背面pdf
  # 制作好后放到/public/download供下载
  def delivery_note_back
    authorize Order, :delivery_note_back?
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: 'delivery_note_back',
               template: '/print/pdf/delivery_note_back.html.slim',
               page_size: 'A5',
               layout: 'pdf.html.slim'
      end
    end
  end

  def sf_express_waybill
    authorize Package, :sf_express_waybill?
    @package = Package.find(params[:id])
    ship_code
    @mailno_barcode = Barby::Code128C.new(@ship_code).to_png
    @package_no_barcode = Barby::Code128B.new(@package.package_no).to_png
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: @package.package_no,
               template: '/print/pdf/sf_express_waybill.html.slim',
               page_height: '150mm',
               page_width: '100mm',
               layout: 'pdf.html.slim',
               margin: { top: 2, bottom: 2, left: 2, right: 2 }
      end
    end
  end

  def yto_express_waybill
    @package = Package.find(params[:id])
    @yto_express = @package.yto_express.all
    @consignee_branch = @yto_express['consignee_branch_code']
    @mail_no = @yto_express['mail_no']
    if @consignee_branch
      @consignee_branch_code = Barby::Code128B.new(@consignee_branch).to_png
    end
    @mail_no_barcode = Barby::Code128C.new(@mail_no).to_png
    @package_no_qr = RQRCode::QRCode.new(@package.package_no, size: 4)
    respond_to do |format|
      format.html
      format.pdf do
        render pdf: '123',
               template: '/print/pdf/yto_express_waybill.html.slim',
               page_height: '180mm',
               page_width: '100mm',
               layout: 'pdf.html.slim',
               margin: { top: 0, bottom: 0, left: 0, right: 0 }
      end
    end
  end

  private

  def set_locale
    return I18n.locale = 'zh-CN' if Region.china?
    super
  end

  def set_locale_in_delivery_note
    return I18n.locale = params[:set_locale] if params[:set_locale].present?
    case @order.billing_info_country_code
    when 'CN'
      I18n.locale = 'zh-CN'
    when 'TW', 'HK', 'MO'
      I18n.locale = 'zh-TW'
    when 'JP'
      I18n.locale = 'ja'
    else
      I18n.locale = 'en'
    end
  end

  def ship_code
    search_result = sf_express_search
    @ship_code = search_result['mailno']
    @destcode = search_result['destcode']
    @origincode = search_result['origincode']
  end

  def sf_express_search
    result = SfExpress::OrderSearch.new(adapter).execute
    fail SfExpressError, result['error'] if result['error'].present?
    result
  end

  def adapter
    @adapter ||= SfExpressAdapter.new(@package)
  end
end
