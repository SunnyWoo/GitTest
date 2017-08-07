require 'spec_helper'

feature 'Payment/Taiwan', :js, come_from: 'Taiwan' do
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

  scenario '可看到新台幣的價格' do
    visit '/'
    expect(page).to have_content('NT$900')
    click_link 'My great work'
    expect(page).to have_content('NT$900')
    click_link '加入購物車'
    expect(page).to have_content('NT$900')
  end

  scenario '可看到應有的付款方式' do
    visit '/'
    click_link 'My great work'
    click_link '加入購物車'
    click_link '結帳'
    expect(page).to have_css('label', text: 'PayPal')
    expect(page).to have_css('label', text: 'ATM 轉帳')
    expect(page).to have_css('label', text: '超商繳費')
    expect(page).to have_css('label', text: '支付寶')
    expect(page).to have_css('label', text: '信用卡支付') # 台灣部分Credit Card的是藍星
  end

  scenario '可看到應有的送貨方式'
end
