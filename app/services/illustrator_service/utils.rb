module IllustratorService::Utils
  def build_qrcode(item)
    qrcode_path = Rails.root.join("tmp", "qrcode-#{item.timestamp_no}.svg").to_s
    File.open(qrcode_path, 'w') { |f| f.write RQRCode::QRCode.new(item.timestamp_no.to_s).as_svg }
    qrcode_path
  end

  def localized_labels(item)
    locale = I18n.locale.to_s
    (labels || []).map do |label|
      locale_content = label[:contents].find { |content| content[:locale] == locale }
      { name: label[:name], content: locale_content[:content] % content_arguments(item) }
    end
  end

  def content_arguments(item)
    {
      order_number: item.order_item.order.order_no,
      product_name: item.order_item.itemable.product_name
    }
  end
end
