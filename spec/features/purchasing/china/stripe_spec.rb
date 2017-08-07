require 'spec_helper'
#非台灣以外地區的Credit Card => Stripe
feature 'Payment/China/Stripe', :js, come_from: 'China' do
  before do
    # 建立新台幣
    create(:currency_type, name: 'TWD', code: 'TWD')
    # 必須有key = 'case'
    category = create(:product_category, key: 'case')
    # 建立 iPhone 5s/5 model
    model = create(:product_model, name: 'iPhone 5s/5', price_table: {'USD' => 99.9, 'TWD' => 900}, category: category)
    # 建立可以買的產品
    create(:featured_work, name: 'My great work', model: 'iPhone 5s/5')
  end

  scenario '可看到正確的總結內容' do
    visit '/'
    click_link 'My great work'
    click_link '加入购物车'
    click_link '立即购买'
    fill_in :shipping_info_name, with: 'Noel'
    fill_in :shipping_info_email, with: 'noel.chen@commandp.me'
    fill_in :shipping_info_address, with: 'Taipei Free Road'
    fill_in :shipping_info_city, with: 'Beijing'
    fill_in :shipping_info_state, with: 'China'
    fill_in :shipping_info_zip_code, with: '800'
    select 'China', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0911222333'
    check :same_as_shipping_info
    choose "信用卡支付"
    click_link '订单明细'
    expect(page).to have_content('Noel')
    expect(page).to have_content('信用卡支付')
  end

  scenario '可以透過 Stripe提供的Credit Card 付款' do
    visit '/'
    click_link 'My great work'
    click_link '加入购物车'
    click_link '立即购买'
    fill_in :shipping_info_name, with: 'Noel'
    fill_in :shipping_info_email, with: 'noel.chen@commandp.me'
    fill_in :shipping_info_address, with: 'Fuxing North Road'
    fill_in :shipping_info_city, with: 'Beijing'
    fill_in :shipping_info_state, with: 'China'
    fill_in :shipping_info_zip_code, with: '800'
    select 'China', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0911222333'
    check :same_as_shipping_info
    choose "信用卡支付"
    click_link '订单明细'
    expect(page).to have_link('Pay with 信用卡支付')
    click_link "Pay with 信用卡支付"
    expect(page).to have_link('订单纪录')
  end
end
