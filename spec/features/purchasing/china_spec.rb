require 'spec_helper'

feature 'Payment/China', :js, come_from: 'China' do
  before do
    # 建立新台幣
    create(:currency_type, name: 'TWD', code: 'TWD')
    # 必須有key = 'case'
    category = create(:product_category, key: 'case')
    # 建立 iPhone 5s/5 model
    model = create(:product_model, name: 'iPhone 5s/5', price_table: {'USD' => 99.9, 'CNY' => 900}, category: category)
    # 建立可以買的產品
    create(:featured_work, name: 'My great work', model: 'iPhone 5s/5')
  end

  scenario '可看到人民幣的價格' do
    visit '/'
    expect(page).to have_content('CN¥ 900')
    click_link 'My great work'
    expect(page).to have_content('CN¥ 900')
    click_link '加入购物车'
    expect(page).to have_content('CN¥ 900')
  end

  scenario '可看到應有的付款方式' do
    visit '/'
    click_link 'My great work'
    click_link '加入购物车'
    click_link '立即购买'
    expect(page).to have_css('label', text: 'PayPal') # FIXME 應為 PayPal
    expect(page).to have_no_css('label', text: '货到付款(RMB 6)')
    expect(page).to have_no_css('label', text: 'ATM 轉帳')
    expect(page).to have_no_css('label', text: '超商繳費')
    expect(page).to have_css('label', text: '支付宝')
    expect(page).to have_css('label', text: '信用卡支付') # 現在這邊的Credit Card是Stripe的
  end

  scenario '收件人國家選擇台灣時, 可看到貨到付款' do
    visit '/'
    click_link 'My great work'
    click_link '加入购物车'
    click_link '立即购买'
    select 'Taiwan', from: :shipping_info_country_code
    expect(page).to have_css('label', text: 'PayPal')
    expect(page).to have_css('label', text: '货到付款(RMB 6)')
    expect(page).to have_no_css('label', text: 'ATM 轉帳')
    expect(page).to have_no_css('label', text: '超商繳費')
    expect(page).to have_css('label', text: '支付宝')
    expect(page).to have_css('label', text: '信用卡支付') # 現在這邊的Credit Card是Stripe的
  end

  scenario '可看到應有的送貨方式'
end
