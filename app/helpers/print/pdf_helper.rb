module Print::PdfHelper
  def wicked_pdf_stylesheet_link_tag(*sources)
    sources.collect do |source|
      "<style type='text/css'>#{Rails.application.assets.find_asset(source + '.css')}</style>"
    end.join('\n').html_safe
  end

  def wicked_pdf_image_tag(img, options = {})
    asset = Rails.application.assets.find_asset(img)
    image_tag "file://#{asset.pathname}", options
  end

  def qrcode_as_html(str)
    RQRCode::QRCode.new(str).as_html.html_safe
  end

  def qrcode_as_svg(str, size = 3)
    RQRCode::QRCode.new(str).as_svg(offset: 0,
                                    color: '000',
                                    shape_rendering: 'crispEdges',
                                    module_size: size).html_safe
  end

  # 为了不让出货单统计信息分开2页显示情形出现
  #
  # 出货单第一页最多可以显示7条order_item
  #     当只有一页的时候需要将5..7放到第二页显示
  # 后面的页面最多可以显示10条order_item
  #     超过一页的最后一页8..10条需要放到后面显示
  def auto_paging_delivery_note(order_items)
    order_items = order_items.to_a
    count = order_items.count
    if count > 7
      start_paging = 8
      last_per_page = 10
      last_page_count = (count - 7) % 10
    else
      start_paging = 5
      last_per_page = 7
      last_page_count = count
    end

    if last_page_count.in? start_paging..last_per_page
      (last_per_page + 1 - last_page_count).times do
        order_items.insert(count - 1, nil)
      end
    end

    order_items
  end

  # convert 994000397192 to 994 000 397 192
  # clone是为了防止insert更改了ship_code
  def render_sf_express_mailno(ship_code)
    return nil if ship_code.blank?
    ship_code.clone.insert(3, ' ').insert(7, ' ').insert(11, ' ')
  end

  def render_order_item_info(order)
    result = []
    order.order_items.group_by(&:itemable).each do |itemable, items|
      result << "#{itemable.product_name} * #{items.map(&:quantity).sum}"
    end
    result.join(' ').html_safe
  end

  def render_product_ticker_logo(order)
    logo = if order.nuandao_b2b?
             'nuandao_logo.png'
           else
             Region.china? ? 'logo_pdf.jpg' : 'logo_black_tw.jpg'
           end
    wicked_pdf_image_tag logo
  end

  def render_company_type(order)
    if order.nuandao_b2b?
      'nuandao'
    else
      Region.region
    end
  end

  def render_product_weight(product)
    desc = Region.china? ? '(含包装)' : nil
    "#{product.weight} g #{desc}"
  end
end
