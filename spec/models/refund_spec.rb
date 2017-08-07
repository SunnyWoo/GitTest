# == Schema Information
#
# Table name: refunds
#
#  id         :integer          not null, primary key
#  order_id   :integer
#  refund_no  :string(255)
#  amount     :float
#  note       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe Refund, :type => :model do
  it "FactoryGirl" do
    expect(build(:refund)).to be_valid
  end
  it { should validate_presence_of(:order_id) }
end
