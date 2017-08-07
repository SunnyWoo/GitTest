class YtoExpress::XmlGenerator
  class_attribute :attributes

  class << self
    def mapping(attribute, options = {})
      self.attributes ||= {}
      attributes[attribute] = options
    end

    def receiver
      {
        name: '',       # 用户姓名
        postCode: '',   # 用户邮编
        phone: '',      # 用户电话，包括区号、电话号码及分机号，中间用“-”分隔；
        mobile: '',     # 用户移动电话， 手机和电话至少填一项
        prov: '',       # 用户所在省
        city: '',       # 用户所在市县（区），市区中间用英文“,”分隔；注意有些市下面没有区
        address: ''     # 用户详细地址
      }
    end

    def sender
      {
        name: '优印仓储',
        postCode: '201700',
        phone: '021-54726621',
        mobile: '',
        prov: '上海',
        city: '上海市,青浦区',
        address: '外青松公路3777弄55号'
      }
    end
  end

  mapping :RequestOrder,
          clientID:             Settings.yto_express.client_id,   #
          logisticProviderID:   'YTO',                            # 物流公司ID
          customerId:           Settings.yto_express.client_id,   # 商家代码
          txLogisticID:         '',                               # 物流订单号
          tradeNo:              '',                               # 业务交易号（可选）
          totalServiceFee:      '',
          codSplitFee:          '',                               # 服务类型(1-上门揽收, 2-次日达 4-次晨达 8-当日达,0-自己联系)。默认为0
          orderType:            '1',                              # 订单类型(0-COD,1-普通订单,2-便携式订单3-退货单)
          serviceType:          '',                               #  服务类型(1-上门揽收, 2-次日达 4-次晨达 8-当日达,0-自己联系)。默认为0
          flag:                 '',                               # 订单flag标识，默认为 0，暂无意义
          sender:               sender,
          receiver:             receiver,
          sendStartTime:        '',
          sendEndTime:          '',
          goodsValue:           '',                               # 商品金额，包括优惠和运费，但无服务费
          items:                ''

  attr_reader :attributes

  def initialize(package_attrs)
    @attributes = self.class.attributes.dup
    @attributes.deep_merge!(package_attrs)
  end

  #  example
  #  <RequestOrder>
  #     <clientID>K24000154</clientID>
  #     <logisticProviderID>YTO</logisticProviderID>
  #     <customerId>K24000154</customerId>
  #     <txLogisticID>WP15183117908113</txLogisticID>
  #     <tradeNo>1</tradeNo>
  #     <totalServiceFee>1</totalServiceFee>
  #     <codSplitFee>1</codSplitFee>
  #     <orderType>1</orderType>
  #     <serviceType>1</serviceType>
  #     <flag>1</flag>
  #     <sender>
  #     <name>发件人姓名</name>
  #         <postCode>526238</postCode>
  #     <phone>021-12345678</phone>
  #         <mobile>18112345678</mobile>
  #     <prov>上海</prov>
  #         <city>上海市,青浦区</city>
  #     <address>华徐公路3029弄28号</address>
  #     </sender>
  #     <receiver>
  #     <name>收件人姓名</name>
  #         <postCode>0</postCode>
  #     <phone>0</phone>
  #         <mobile>18089666766</mobile>
  #     <prov>上海</prov>
  #         <city>上海市,青浦区</city>
  #     <address>华徐公路3029弄28号</address>
  #     </receiver>
  #     <sendStartTime>2015-12-12 12:12:12</sendStartTime>
  #     <sendEndTime>2015-12-12 12:12:12</sendEndTime>
  #     <goodsValue>1</goodsValue>
  #     <items>
  #         <item>
  #             <itemName>商品</itemName>
  #     <number>2</number>
  #             <itemValue>0</itemValue>
  #     </item>
  #     </items>
  #     <insuranceValue>1</insuranceValue>
  #     <special>1</special>
  #     <remark>1</remark>
  # </RequestOrder>
  def generate
    Gyoku.xml(attributes.as_json)
  end
end
