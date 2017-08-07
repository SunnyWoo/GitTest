require 'spec_helper'

feature 'Payment/Hong Kong', :js, come_from: 'Hong Kong' do
  before do
    # 建立日元
    create(:currency_type, name: 'HKD', code: 'HKD')
    # 必須有key = 'case'
    category = create(:product_category, key: 'case')
    # 建立 iPhone 5s/5 model
    model = create(:product_model, name: 'iPhone 5s/5', price_table: {'USD' => 99.9, 'HKD' => 229}, category: category)
    # 建立可以買的產品
    create(:featured_work, name: 'My great work', model: 'iPhone 5s/5')
  end

  scenario '可看到港幣的價格' do
    visit '/'
    expect(page).to have_content('229')
    click_link 'My great work'
    expect(page).to have_content('229')
    click_link 'Add to Cart'
    expect(page).to have_content('229')
  end

  scenario '可看到應有的付款方式' do
    visit '/'
    click_link 'My great work'
    click_link 'Add to Cart'
    click_link 'Check Out'
    expect(page).to have_css('label', text: 'PayPal')
    expect(page).to have_no_css('label', text: '貨到付款(NT$30)')
    expect(page).to have_no_css('label', text: 'ATM 轉帳')
    expect(page).to have_no_css('label', text: '超商繳費')
    expect(page).to have_no_css('label', text: '支付寶')
    expect(page).to have_css('label', text: 'Credit Card') # 現在這邊的Credit Card是Stripe的
  end

  scenario '可看到應有的送貨方式'
end
