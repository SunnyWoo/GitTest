require 'spec_helper'

feature CartController, :js do
  let!(:user) { create(:user, :with_facebook) }

  before do
    # 必須有key = 'case'
    category = create(:product_category, key: 'case')
    @work = create(:work, name: 'Phone Case', work_type: :is_public, featured: true, category: category)
  end

  context 'guest user' do

    it 'visit index' do
      visit root_path
      expect(page).to have_content('Phone Case')
    end

    it 'click Add to Cart' do
      #add item to cart
      visit work_path(:en, @work.id)

      expect(page).to have_content('Phone Case')
      find(:class, '.add_to_cart').click

      # #cart index
      expect(page).to have_content('Your Shopping Cart')
      expect(page).to have_content('1 item')
      expect(page).to have_content('Check Out')
      click_link 'Check '

      # Check Out Page
      expect(page).to have_content('Check Out') # Check Out
      expect(page).to have_content('Summary') # Summary
      expect(page).to have_content(@work.model_name)
    end

  end

  context 'login user' do
    before do
      include Warden::Test::Helpers
      Warden.test_mode!
    end

    it "create work" do
      login_as(user, :scope => :user)
      visit root_path
    end
  end
end
