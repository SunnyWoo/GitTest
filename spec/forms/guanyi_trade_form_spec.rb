require 'spec_helper'

describe GuanyiTradeForm do
  Given(:order) { create(:order) }
  Given(:product_model) { create(:product_model, key: 'iphone_5_cases_cn') }
  Given(:work) { create(:work, product: product_model) }
  Given!(:order_item) { create(:order_item, order: order, itemable: work) }
  Given(:form) { GuanyiTradeForm.new(order.reload) }
  Then { form.valid? }

  context '#post!' do
    When { form.service = GuanyiService.new }
    Given(:result) do
      {
        success: true,
        errorCode: '',
        subErrorCode: '',
        errorDesc: '',
        subErrorDesc: '',
        requestMethod: 'gy.erp.trade.add',
        id: 7_024_677_467,
        code: 'SO7024677467',
        created: '2015-10-16 19:53:44'
      }
    end
    before { expect(form.service).to receive(:request).with('gy.erp.trade.add', form.attributes).and_return(result) }
    Then { form.post! }
  end

  context '#attributes' do
    before { order.shipping_info.update(phone: '+886-2-2753-3555') }
    Then { form.attributes[:receiver_mobile] == '886-2-2753-3555' }
  end
end
