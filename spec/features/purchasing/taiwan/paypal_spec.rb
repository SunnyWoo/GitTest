require 'spec_helper'

feature 'Payment/Taiwan/Paypal', :js, come_from: 'Taiwan' do
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
    click_link '加入購物車'
    click_link '立刻結帳'
    fill_in :shipping_info_name, with: 'ayaya'
    fill_in :shipping_info_email, with: 'ayaya@commandp.me'
    fill_in :shipping_info_address, with: 'Fuxing North Road'
    fill_in :shipping_info_city, with: 'Taipei'
    fill_in :shipping_info_state, with: 'Taiwan'
    fill_in :shipping_info_zip_code, with: '800'
    select 'Taiwan', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0912345678'
    check :same_as_shipping_info
    click_link '結帳明細'
    expect(page).to have_content('ayaya')
    expect(page).to have_content('PayPal')
  end

  scenario '可以透過 PayPal 付款' do
    visit '/'
    click_link 'My great work'
    click_link '加入購物車'
    click_link '立刻結帳'
    fill_in :shipping_info_name, with: 'ayaya'
    fill_in :shipping_info_email, with: 'ayaya@commandp.me'
    fill_in :shipping_info_address, with: 'Fuxing North Road'
    fill_in :shipping_info_city, with: 'Taipei'
    fill_in :shipping_info_state, with: 'Taiwan'
    fill_in :shipping_info_zip_code, with: '800'
    select 'Taiwan', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0912345678'
    check :same_as_shipping_info
    click_link '結帳明細'
    expect(page).to have_link('Pay with PayPal')
  end
end
