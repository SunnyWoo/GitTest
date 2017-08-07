require 'spec_helper'

describe Admin::MobileUisController, type: :request do
  before(:each) do
    create(:fee, name: '運費')
    create(:product_model)
    login_admin
  end

  it "#index" do
    get admin_mobile_uis_path
    expect(response).to be_success
  end

  it '#new' do
    get new_admin_mobile_ui_path
    expect(response).to be_success
  end

  it "#create" do
    count = MobileUi.count
    data = { title: 'Test King', template: "shop", start_at: 1.day.ago,
             end_at: 1.month.from_now, image: fixture_file_upload('test.jpg') }
    post admin_mobile_uis_path, mobile_ui: data
    expect(response).to be_redirect
    expect(MobileUi.count).to eq(count + 1)
  end

  context "when new, update, and destroy" do
    let!(:ios_ui){ create(:mobile_ui) }

    it "#edit" do
      get edit_admin_mobile_ui_path(ios_ui)
      expect(response).to be_success
    end

    it "#update" do
      data = { title: "Test Queen", template: "user" }
      put admin_mobile_ui_path(ios_ui), mobile_ui: data
      expect(response).to be_redirect
      expect(ios_ui.reload.title).to eq "Test Queen"
      expect(ios_ui.reload.template).to eq "user"
    end

    it "#destroy" do
      count = MobileUi.count
      delete admin_mobile_ui_path(ios_ui)
      expect(MobileUi.count).to eq(count - 1)
    end
  end

end
