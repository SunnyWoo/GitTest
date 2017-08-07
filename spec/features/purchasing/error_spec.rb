require 'spec_helper'

feature 'Payment/Taiwan', :js, come_from: 'Taiwan' do
  before do
    # 建立新台幣
    create(:currency_type, name: 'TWD', code: 'TWD')
    # 建立 iPhone 5s/5 model
    model = create(:product_model, name: 'iPhone 5s/5', price_table: {'USD' => 99.9, 'TWD' => 900})
    # 建立可以買的產品
    create(:featured_work, name: 'My great work', model: 'iPhone 5s/5')
  end
end
