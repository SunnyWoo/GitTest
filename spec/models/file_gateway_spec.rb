# == Schema Information
#
# Table name: file_gateways
#
#  id           :integer          not null, primary key
#  type         :string(255)
#  factory_id   :integer
#  connect_info :hstore
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe FileGateway do
  it 'FactoryGirl' do
    expect(build(:file_gateway)).to be_valid
  end
end
