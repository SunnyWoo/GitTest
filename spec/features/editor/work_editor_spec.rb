require 'spec_helper'

describe 'Work editor', type: :feature do
  xit 'visitable' do
    create(:product_model, name: 'iPhone 5s/5')

    visit '/'
    click_link 'CREATE'
    click_link 'iPhone 5s/5'
    expect(page.current_path).to match(%r'/en/editor/works/\d+/edit')

    expect(Work.last).to be_present
    expect(Work.last.user).to be_guest
    expect(User.last).to be_present
  end
end
