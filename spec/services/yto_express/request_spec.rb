require 'spec_helper'

RSpec.describe YtoExpress::Request do
  context '#post', :vcr do
    Given(:request_xml) do
      '<RequestOrder>
        <clientID>K10101010</clientID>
        <logisticProviderID>YTO</logisticProviderID>
        <customerId>K10101010</customerId>
        <txLogisticID>WP15183117908113</txLogisticID>
        <tradeNo>1</tradeNo>
        <totalServiceFee>1</totalServiceFee>
        <codSplitFee>1</codSplitFee>
        <orderType>1</orderType>
        <serviceType>1</serviceType>
        <flag>1</flag>
        <sender>
        <name>发件人姓名</name>
            <postCode>526238</postCode>
        <phone>021-12345678</phone>
            <mobile>18112345678</mobile>
        <prov>上海</prov>
            <city>上海市,青浦区</city>
        <address>华徐公路3029弄28号</address>
        </sender>
        <receiver>
        <name>收件人姓名</name>
            <postCode>0</postCode>
        <phone>0</phone>
            <mobile>18089666766</mobile>
        <prov>上海</prov>
            <city>上海市,青浦区</city>
        <address>华徐公路3029弄28号</address>
        </receiver>
        <sendStartTime>2015-12-12 12:12:12</sendStartTime>
        <sendEndTime>2015-12-12 12:12:12</sendEndTime>
        <goodsValue>1</goodsValue>
        <items>
            <item>
                <itemName>商品</itemName>
        <number>2</number>
                <itemValue>0</itemValue>
        </item>
        </items>
        <insuranceValue>1</insuranceValue>
        <special>1</special>
        <remark>1</remark>
      </RequestOrder>'
    end
    Given(:response) do
      {
        mail_no: '858591112493',
        tx_logistic_id: 'WP15183117908113',
        short_address: '300-006-000',
        consignee_branch_code: '210185',
        package_center_code: '210901',
        package_center_name: '上海转运中心'
      }
    end
    Then { YtoExpress::Request.new(request_xml).post == response }
  end
end
