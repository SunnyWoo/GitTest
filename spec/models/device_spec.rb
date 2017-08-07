# == Schema Information
#
# Table name: devices
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  token           :string(255)
#  detail          :text
#  os_version      :string(255)
#  device_type     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  endpoint_arn    :string(255)
#  country_code    :string(255)
#  timezone        :string(255)
#  is_enabled      :boolean          default(TRUE)
#  getui_client_id :string(255)
#  idfa            :string(255)
#

require 'spec_helper'

describe Device do
  it 'FactoryGirl' do
    expect(build(:device)).to be_valid
  end

  it { should belong_to(:user) }

  context '#create_endpoint_arn' do
    it 'when rgeion is china' do
      stub_env('REGION', 'china')
      device = create(:device)
      expect(device.create_endpoint_arn).to be_nil
    end
  end
end
