class Webhook::SfExpressController < ApplicationController
  skip_before_action :set_locale, :authenticate
  skip_before_action :verify_authenticity_token

  # 路由推送
  # http://www.sf-express.com/cn/sc/platform/sd/detail/routepush.html
  # post /webhook/sf_express/route
  #
  # request params[:content]
  #
  # <Request service="RoutePushService" lang="zh-CN">
  #   <Body>
  #     <WaybillRoute id="路由编号" mailno="运单号" orderid="订单号" acceptTime="路由发生时间"
  #                  acceptAddress="路由发生地点" remark="详细说明" opCode="操作码"/>
  #      <!--//...最多10个<WaybillRoute>-->
  #   </Body>
  # </Request>

  def route
    xml_params = Nokogiri::XML(params[:content])
    xml_params.xpath('//WaybillRoute').to_a.each do |waybill_route_xml|
      package_no = waybill_route_xml.attribute('orderid').value
      package = Package.find_by(package_no: package_no)
      package.waybill_routes.create(waybill_route_attributes(waybill_route_xml))
    end
    render xml: success_response
  rescue
    render xml: error_response
  end

  private

  def success_response
    Gyoku.xml(
      'Response' => {
        'Head' => 'OK'
      }, :attributes! => { 'Response' => { 'service' => 'RoutePushService' } }
    )
  end

  def error_response
    Gyoku.xml(
      'Response' => {
        'Head' => 'ERR',
        'Error' => 'error',
        :attributes! => { 'Error' => { 'code' => 'error code' } }
      }, :attributes! => { 'Response' => { 'service' => 'RoutePushService' } }
    )
  end

  def waybill_route_attributes(waybill_route_xml)
    route_no = waybill_route_xml.attribute('id').value
    mail_no = waybill_route_xml.attribute('mailno').value
    accept_time = waybill_route_xml.attribute('acceptTime').value
    accept_address = waybill_route_xml.attribute('acceptAddress').value
    remark = waybill_route_xml.attribute('remark').value
    op_code = waybill_route_xml.attribute('opCode').value

    {
      route_no: route_no,
      mail_no: mail_no,
      accept_time: accept_time.present? ? DateTime.parse(accept_time).in_time_zone : nil,
      accept_address: accept_address,
      remark: remark,
      op_code: op_code
    }
  end
end
