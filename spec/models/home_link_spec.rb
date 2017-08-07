# == Schema Information
#
# Table name: home_links
#
#  id         :integer          not null, primary key
#  href       :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe HomeLink, type: :model do
  it "FactoryGirl" do
    expect(create(:home_link)).to be_valid
  end
end
