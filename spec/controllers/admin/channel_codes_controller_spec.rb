require 'rails_helper'

RSpec.describe Admin::ChannelCodesController, :admin, type: :controller do
  Given!(:channel_code) { create :channel_code }

  context '#index' do
    When { get :index }
    Then { response.status == 200 }
    And { assigns(:channel_codes) == [channel_code] }
  end

  context '#create' do
    When { post :create, channel_code: { code: '000', description: 'commandp' } }
    Then { ChannelCode.last.code == '000' }
    And { ChannelCode.last.description == 'commandp' }
  end
end
