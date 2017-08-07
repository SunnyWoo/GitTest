require 'spec_helper'

describe AddressInfosController, type: :controller do
  describe 'matches redirect_to' do
    Given(:reg) { AddressInfosController::REDIRECT_PATH_REG }
    Then { '/zh-TW/cart/check_out'.match(reg) }
    And { '/zh-TW/users/address'.match(reg) }
    And { '/en/users/address'.match(reg) }
    And { '/ja-JP/users/address'.match(reg) }
    And { 'http://xxxxx.xxx'.match(reg).blank? }
    And { '/en/cart/add'.match(reg).blank? }
  end

  describe '#find_redirect_to' do
    before do
      @user = create(:user)
      sign_in @user
      @address_info = create(:address_info, billable: @user)
    end

    it 'return ok, with redirect_to /zh-TW/cart/check_out' do
      redirect_to_path = '/zh-TW/cart/check_out'
      post :create, locale: 'zh-TW', address_info: { name: 'office' }, redirect_to: redirect_to_path
      expect(response).to redirect_to(redirect_to_path)
    end

    ['/en/cart/add'].each do |redirect_to_path|
      it "Invalid path: #{redirect_to_path}, with redirect_to /en/cart/check_out" do
        post :create, locale: 'en', address_info: { name: 'office' }, redirect_to: redirect_to_path
        expect(response).not_to redirect_to(redirect_to_path)
        expect(response).to redirect_to('/en/cart/check_out')
      end
    end
  end
end
