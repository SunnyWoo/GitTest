require 'spec_helper'

feature 'Locale', :js do
  scenario '自動決定語系' do
    page.driver.add_header('Accept-Language', 'zh-TW')
    visit '/'
    expect(page).to have_css('.locale-zh-TW')
  end

  scenario '手動決定語系' do
    visit '/en'
    expect(page).to have_css('.locale-en')
  end

  scenario '手動決定語系, 忽略不支援的國碼' do
    visit '/en-US'
    expect(page).to have_css('.locale-en')
  end

  scenario 'zh 特別處理' do
    visit '/zh'
    expect(page).to have_css('.locale-zh-TW')
  end

  scenario '不支援的語系, 使用 en' do
    visit '/kr'
    expect(page).to have_css('.locale-en')
  end
end
