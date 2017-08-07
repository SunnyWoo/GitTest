require 'spec_helper'

feature AdminController do

  before(:each) { login_admin }

  context "Something didn't set" do

    scenario "don't have any CurrencyType" do
      visit '/admin'
      expect(current_path).to eq(url_for([:new, :admin, :currency_type, only_path: true, locale: I18n.locale]))
      expect(page).to have_content('必須先設定支援貨幣類型，目前沒有任何貨幣類型')
    end

    scenario "Shipping fee isn't set yet" do
      create(:currency_type)
      visit '/admin'
      expect(current_path).to eq(url_for([:edit, :admin, shipping_fee, only_path: true, locale: I18n.locale]))
      expect(page).to have_content('必須先設定運費價格')
    end

    scenario "ProductModel isn't set yet" do
      create(:currency_type)
      setup_shipping_fee
      visit '/admin'
      expect(current_path).to eq(url_for([:new, :admin, :product_model, only_path: true, locale: I18n.locale]))
      expect(page).to have_content('必須先設定商品類型，目前沒有任何商品類型')
    end

  end

  context "All things setup correctly" do

    scenario "get path I want" do
      create(:currency_type)
      create(:product_model)
      setup_shipping_fee
      visit '/admin'
      expect(current_path).to eq('/admin')
    end

  end


end
