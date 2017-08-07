require 'spec_helper'
#非台灣以外地區的Credit Card => Stripe
feature 'Payment/Japan/Stripe', :js, come_from: 'Japan' do
  before do
    # 建立日圓
    create(:currency_type, name: 'JPY', code: 'JPY')
    # 必須有key = 'case'
    category = create(:product_category, key: 'case')
    # 建立 iPhone 5s/5 model
    model = create(:product_model, name: 'iPhone 5s/5', price_table: {'USD' => 99.9, 'JPY' => 3180}, category: category)
    # 建立可以買的產品
    create(:featured_work, name: 'My great work', model: 'iPhone 5s/5')
  end

  scenario '可看到正確的總結內容' do
    visit '/'
    click_link 'My great work'
    click_link 'カートに入れる'
    click_link 'レジに進む'
    fill_in :shipping_info_name, with: 'Noel'
    fill_in :shipping_info_email, with: 'noel.chen@commandp.me'
    fill_in :shipping_info_address, with: 'Taipei Free Road'
    fill_in :shipping_info_city, with: 'Taipei'
    fill_in :shipping_info_state, with: 'Japan'
    fill_in :shipping_info_zip_code, with: '800'
    select 'Japan', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0911222333'
    check :same_as_shipping_info
    choose "クレジットカード決済"
    click_link '確認'
    expect(page).to have_content('Noel')
    expect(page).to have_content('クレジットカード決済')
  end

  scenario '可以透過 Stripe提供的Credit Card 付款' do
    visit '/'
    click_link 'My great work'
    click_link 'カートに入れる'
    click_link 'レジに進む'
    fill_in :shipping_info_name, with: 'Noel'
    fill_in :shipping_info_email, with: 'noel.chen@commandp.me'
    fill_in :shipping_info_address, with: 'Fuxing North Road'
    fill_in :shipping_info_city, with: 'Taipei'
    fill_in :shipping_info_state, with: 'Japan'
    fill_in :shipping_info_zip_code, with: '800'
    select 'Japan', from: :shipping_info_country_code
    fill_in :shipping_info_phone, with: '0911222333'
    check :same_as_shipping_info
    choose "クレジットカード決済"
    click_link '確認'
    expect(page).to have_link('Pay with クレジットカード決済')
    click_link "Pay with クレジットカード決済"
    expect(page).to have_button('Pay 3,180円')
  end
end
