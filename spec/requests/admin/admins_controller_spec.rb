require 'spec_helper'

describe Admin::AdminsController, type: :request do
  before(:each) do
    setup_admin
    login_admin
  end

  it '#log' do
    get log_admin_admin_path(Admin.last)
    expect(response.status).to eq 200
  end

  it '#unlock' do
    admin = Admin.last
    admin.lock_access!
    expect(admin.access_locked?).to eq true
    patch unlock_admin_admin_path(admin)
    expect(response).to be_redirect
    expect(admin.reload.access_locked?).to eq false
  end
end
