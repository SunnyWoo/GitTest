require 'spec_helper'

feature 'Admin pages', :js do
  before do
    create(:fee, name: '運費')
    create(:product_model)
    Fee.all.each do |fee|
      create(:currency, payable: fee)
    end
    login_admin
  end

  %w[/admin
     /admin/site_settings
     /admin/users
     /admin/admins
     /admin/designers
     /admin/activities
     /admin/works
     /admin/archived_works
     /admin/work_sets
     /admin/tags
     /admin/asset_packages
     /admin/orders
     /admin/orders/unapproved
     /admin/orders/approve_invoice
     /admin/currency_types
     /admin/price_tiers
     /admin/product_models
     /admin/products
     /admin/coupons
     /admin/emails
     /admin/messages
     /admin/questions
     /admin/question_categories
     /admin/reports
     /admin/features
     /admin/home_products
     /admin/home_slides
     /admin/home_links
     /admin/home_blocks
     /admin/banners
     /admin/mobile_uis
     /admin/announcements
     /admin/notifications
     /admin/newsletters].each do |path|
    it 'is visible' do
      should_visible(path)
    end
  end

  def should_visible(path)
    visit(path)
    expect(page.status_code).to eq(200)
    expect(page.current_path).to match(path)
  end
end
