require 'spec_helper'

RSpec.describe Admin::HomeLinksController, type: :request do
  before(:each) do
    create(:fee, name: '運費')
    create(:product_model)
    login_admin
  end

  it '#index' do
    get admin_home_links_path
    expect(response).to be_success
  end

  it "#new" do
    get new_admin_home_link_path
    expect(response).to be_success
  end

  it "#create" do
    count = HomeLink.count
    data = { href: "http://zh.wikipedia.org/wiki/%E6%9E%97%E6%BD%A4%E5%A6%B8", position: 1, translations_attributes: { "0" => { locale: :en, name: "Yoona" }, "1" => { locale: :"zh-TW", name: "潤娥"} } }
    post admin_home_links_path, home_link: data
    expect(response).to be_redirect
    expect(HomeLink.count).to eq(count + 1)
    expect(HomeLink.last.name).to eq("Yoona")
    I18n.locale = :"zh-TW"
    expect(HomeLink.last.name).to eq("潤娥")
  end

  context "edit, update, or destroy" do
    let!(:link){ create :home_link }

    it '#edit' do
      get edit_admin_home_link_path(link)
      expect(response).to be_success
    end

    it "#update" do
      data = { href: "https://www.tumblr.com/tagged/yoona", translations_attributes: { "0" => { id: link.translations.first.id, name: "Manchester United" } } }
      put admin_home_link_path(link), home_link: data
      expect(response).to be_redirect
      expect(link.reload.href).to eq data[:href]
      expect(link.name).to eq "Manchester United"
    end

    it "#destroy" do
      count = HomeLink.count
      delete admin_home_link_path(link)
      expect(HomeLink.count).to eq(count - 1)
    end
  end


end
