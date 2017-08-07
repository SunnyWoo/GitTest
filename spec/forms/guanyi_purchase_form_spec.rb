require 'spec_helper'

describe GuanyiPurchaseForm do
  Given(:order) { create(:order) }
  Given(:product_model) { create(:product_model, key: 'iphone_5_cases_cn') }
  Given(:work) { create(:work, product: product_model) }
  Given!(:order_item) { create(:order_item, order: order, itemable: work) }
  Given!(:product_reference) { create :purchase_product_reference, product_id: product_model.id }
  before do
    allow(product_reference).to receive(:purchase_price).and_return('22.22')
    allow(Purchase::ProductReference).to receive(:find_by).and_return(product_reference)
  end
  Given(:form) { GuanyiPurchaseForm.new(order.reload) }

  Then { form.valid? }

  context '#post!' do
    Given(:result) do
      {
        success: true,
        errorCode: '',
        subErrorCode: '',
        errorDesc: '',
        subErrorDesc: '',
        requestMethod: 'gy.erp.purchase.arrive.add',
        code: 'PAO7025230178'
      }
    end
    When { form.service = GuanyiService.new }
    When { expect(form.service).to receive(:request).with('gy.erp.purchase.arrive.add', form.attributes) { result } }
    Then { form.post! }
  end
end
