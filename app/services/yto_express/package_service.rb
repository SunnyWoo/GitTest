class YtoExpress::PackageService
  include YtoExpress::Errors
  attr_reader :package

  def initialize(package)
    @package = package
  end

  def request_xml
    YtoExpress::XmlGenerator.new(attributes).generate
  end

  def post
    @response = YtoExpress::Request.new(request_xml).post
    store_yto_express if @response[:success]
    @response
  rescue => e
    errors.add(:base, e.to_s)
    false
  end

  def store_yto_express
    @response.slice(:mail_no, :short_address, :consignee_branch_code, :package_center_code).each do |key, value|
      package.yto_express[key] = value
    end
  end

  def attributes
    {
      RequestOrder: {
        receiver: receiver_attributes,
        items: { item: items_attributes },
        txLogisticID: package.package_no

      }
    }
  end

  private

  def receiver_attributes
    {
      name: package.shipping_info_name,
      postCode: package.shipping_info_zip_code,
      phone: package.shipping_info_phone.gsub(/[+]/, ''),
      mobile: '',
      prov: package.shipping_info.province_name || package.shipping_info.address_data.province,
      city: package.shipping_info_city,
      address: package.shipping_info_address,
    }
  end

  def items_attributes
    package.print_items.map do |print_item|
      item_name = print_item.order_item.itemable.name
      {
        itemName: item_name.present? ? item_name : '客制化',
        number: 1,
        itemValue: print_item.order_item.original_price_in_currency('CNY')
      }
    end
  end
end
