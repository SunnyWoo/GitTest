require 'spec_helper'

RSpec.describe 'api/v3/_device.json.jbuilder', :caching, type: :view do
  let(:device) { create(:device) }

  it 'renders device', :vcr do
    render 'api/v3/device', device: device
    expect(JSON.parse(rendered)).to eq(
      'id' => device.id,
      'user_id' => device.user_id,
      'token' => device.token,
      'detail' => device.detail,
      'os_version' => device.os_version,
      'device_type' => device.device_type,
      'endpoint_arn' => device.endpoint_arn,
      'getui_client_id' => device.getui_client_id,
      'country_code' => device.country_code,
      'timezone' => device.timezone,
      'idfa' => device.idfa
    )
  end
end
