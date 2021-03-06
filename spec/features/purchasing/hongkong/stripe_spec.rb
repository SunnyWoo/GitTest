require 'spec_helper'
#非台灣以外地區的Credit Card => Stripe
feature 'Payment/Hong Kong/Stripe', :js, come_from: 'Hong Kong' do
  before do
    # 建立港幣
    create(:currency_type, name: 'HKD', code: 'HKD')
    # 必須有key = 'case'
    category = create(:product_category, key: 'case')
    # 建立 iPhone 5s/5 model
    model = create(:product_model, name: 'iPhone 5s/5', price_table: {'USD' => 99.9, 'HKD' => 229}, category: category)
    # 建立可以買的產品
    create(:featured_work, name: 'My great work', model: 'iPhone 5s/5')
  end

  scenario '可看到正確的總結內容' do
    visit '/'
    click_link 'My great work'
    click_link 'Add to Cart'
    click_link 'Check Out'
    fill_in :shipping_info_name, with: 'Noel'
    fill_in :shipping_info_email, with: 'noel.chen@commandp.me'
    fill_in :shipping_info_address, with: 'Hong Kong Free Road'
    fill_in :shipping_info_city, with: 'Hong Kong'
    fill_in :shipping_info_state, with: 'Hong Kong'
    fill_in :shipping_info_zip_code, with: '800'
    select 'Hong Kong', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0911222333'
    check :same_as_shipping_info
    choose "Credit Card"
    click_link 'Summary'
    expect(page).to have_content('Noel')
    expect(page).to have_content('Credit Card')
  end

  scenario '可以透過 Stripe提供的Credit Card 付款' do
    visit '/'
    click_link 'My great work'
    click_link 'Add to Cart'
    click_link 'Check Out'
    fill_in :shipping_info_name, with: 'Noel'
    fill_in :shipping_info_email, with: 'noel.chen@commandp.me'
    fill_in :shipping_info_address, with: 'Hong Kong Free Road'
    fill_in :shipping_info_city, with: 'Hong Kong'
    fill_in :shipping_info_state, with: 'Hong Kong'
    fill_in :shipping_info_zip_code, with: '800'
    select 'Hong Kong', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0911222333'
    check :same_as_shipping_info
    choose "Credit Card"
    click_link 'Summary'
    expect(page).to have_link('Pay with Credit Card')
    click_link "Pay with Credit Card"
    expect(page).to have_button('Pay')
  end
end
