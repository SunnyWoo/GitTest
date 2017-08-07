require 'rails_helper'

RSpec.describe Webhook::SfExpressController, type: :controller do
  context '#route' do
    Given(:content) do
      <<MSG
<Request service="RoutePushService" lang="zh-CN">
  <Body>
    <WaybillRoute id="路由编号" mailno="运单号" orderid="orderid" acceptTime="2015-02-01 10:00:00"
                 acceptAddress="路由发生地点" remark="详细说明" opCode="操作码"/>
     <!--//...最多10个<WaybillRoute>-->
  </Body>
</Request>
MSG
    end
    context 'return error_response if order is not found' do
      When { post :route, content: content }
      Then { response.body == controller.send(:error_response) }
    end

    context 'return success_response if order is found and create the waybill_routes' do
      Given!(:package) { create(:package) }
      before { expect(Package).to receive(:find_by).and_return(package) }
      When { post :route, content: content }
      Then { response.body == controller.send(:success_response) }
      Given(:waybill_route) { package.waybill_routes.last }
      And { waybill_route.route_no == '路由编号' }
      And { waybill_route.mail_no == '运单号' }
      And { waybill_route.accept_address == '路由发生地点' }
      And { waybill_route.remark == '详细说明' }
      And { waybill_route.op_code == '操作码' }
    end
  end
end
