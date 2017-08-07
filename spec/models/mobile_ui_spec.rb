# == Schema Information
#
# Table name: mobile_uis
#
#  id          :integer          not null, primary key
#  title       :string(255)
#  description :string(255)
#  template    :string(255)
#  image       :string(255)
#  priority    :integer          default(1)
#  start_at    :date
#  end_at      :date
#  is_enabled  :boolean          default(FALSE)
#  created_at  :datetime
#  updated_at  :datetime
#  default     :boolean          default(FALSE)
#

require 'rails_helper'

RSpec.describe MobileUi, type: :model do
  it "FactoryGirl" do
    expect(create(:mobile_ui)).to be_valid
  end
end
