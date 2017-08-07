require 'spec_helper'
include Devise::TestHelpers

feature PrintController do

  context 'print flow' do
    before do
      @factory_member = login_factory_member
      @order = create(:order)
      @order.pay!
      @order.reload
      @order.order_items.each{ |order_item| order_item.clone_to_print_items }
    end

    # FIXME: 無法顯示正確的 product models
    xit 'index / Upload print image to FTP' do
      print_item = @order.print_items.first
      @factory_member.factory.product_models << print_item.model
      visit print_print_path(model_id: print_item.model_id)
      expect(page).to have_content('印刷工作站')

      expect(page).to have_content(print_item.id)
      expect(page).to have_content(print_item.model_name)
      expect(page).to have_content(print_item.print_image.url)
    end

    context 'sublimate' do
      before do
        @order.print_items.each do |print_item|
          print_item.update! aasm_state: :printed
        end
        @print_item = @order.print_items.first
        @factory_member.factory.product_models << @print_item.model
        visit print_sublimate_path(model_id: @print_item.model_id)
      end

      it 'list' do
        expect(page).to have_content('熱轉印工作站')
        expect(page).to have_content(@print_item.model_name)
        expect(page).to have_content(@print_item.print_image.url)
      end

      it 'button' do
        # 檢查 link button
        expect(find(:class, '.sublimate_print_sticker')).not_to be_nil
        expect(find(:class, '.sublimate_finish')).not_to be_nil
        # click 列印貼紙
        find(:class, '.sublimate_print_sticker').click
        expect(page).to have_content(@print_item.timestamp_no)
      end
    end

    context 'package' do
      before do
        @order.print_items.each{ |print_item| print_item.update! aasm_state: :sublimated }
        visit print_package_path
      end

      it 'list' do
        expect(page).to have_content('包裝工作站')
        expect(page).to have_content(@order.order_no)
        find_link('打包')
      end
    end

    context 'ship' do
      before do
        @order.print_items.each{ |p| p.update_attribute(:aasm_state, 'onboard') }
        @order.order_items.each{ |o| o.update_attribute(:aasm_state, 'onboard') }
        @order.update_attribute(:aasm_state, 'packaged')
        visit print_ship_path
      end

      it 'list' do
        expect(page).to have_content('出貨工作站')
        expect(page).to have_content(@order.order_no)
        expect(page.html.match(/print\/orders\/#{@order.id}/)).not_to be_nil
      end

      it 'click print' do
        find('#print_item_info').click
        expect(page).to have_content("Order ID : #{@order.order_no}")
        expect(page).to have_content('SHIPPING ADDRESS')
        expect(page).to have_content(@order.print_items.first.timestamp_no)
      end

      it 'type ship code' do
        expect(find(:class, '.ship_submit.disabled')).not_to be nil
        fill_in 'ship_code', with: 'no1234567'
        expect(find(:class, '.ship_submit')).not_to be nil
      end
    end
  end

  it 'vist print search' do
    login_factory_member
    visit print_search_path
    expect(page).not_to  have_content('Search:')
    expect(page).to  have_content('Print Dashboard')
  end

  context 'search' do
    before do
      login_factory_member
    end
    it 'search order_no don\'t have result' do
      visit print_sublimate_path
      fill_in 'print_search_order_no', with: "123"
      click_button 'print_search_order_submit'
      expect(page).not_to  have_content('Search: 1234')
      expect(page).to  have_content('無結果')
    end

    it 'search order_no have result' do
      order = create(:order)
      order.pay!
      order.reload
      order.order_items.first.clone_to_print_items
      visit print_sublimate_path
      fill_in 'print_search_order_no', with: order.order_no
      click_button 'print_search_order_submit'
      expect(page).to have_content("Search: #{order.order_no}")
      expect(page).not_to  have_content('無結果')
    end
  end
end
