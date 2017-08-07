require 'spec_helper'

describe 'Admin login', type: :request do
  before do
    create(:fee, name: '運費')
    create(:product_model)
    Fee.all.each do |fee|
      create(:currency, payable: fee)
    end
  end

  context 'login' do
    let!(:admin) { create :admin }

    it 'should be_redirect when success' do
      post admin_session_path, admin: { email: admin.email, password: admin.password }
      expect(response).to be_redirect
    end

    it 'should redirect_to root_path when fail' do
      post admin_session_path, admin: { email: admin.email, password: 'WtF123412' }
      expect(response).to redirect_to root_path
      expect(admin.reload.failed_attempts).to eq(1)
    end

    it 'should lock the admin after fail for over 5 times' do
      5.times do
        post admin_session_path, admin: { email: admin.email, password: 'WtF123412' }
      end
      expect(response).to redirect_to root_path
      expect(admin.reload.failed_attempts).to eq(5)
      expect(admin.access_locked?).to eq true
    end
  end
end
