require 'spec_helper'

RSpec.describe CampaignController, type: :request do
  context '#duncan' do
    it 'render 302 when locale is not zh-TW' do
      get campaign_path(:duncan, locale: 'en')
      expect(response.code.to_i).to eq 302

      enable_feature! :duncan
      get campaign_path(:duncan, locale: 'en')
      expect(response.code.to_i).to eq 302
    end

    it 'render ok when feature flag duncan on' do
      enable_feature! :duncan
      get campaign_path(:duncan, locale: 'zh-TW')
      expect(response).to be_success
    end

    it 'render 404 when feature flag duncan off and locale is zh-TW' do
      get campaign_path(:duncan, locale: 'zh-TW')
      expect(response.code.to_i).to eq 404
    end

    it 'render ok when feature flag duncan on and come from china shanghai' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('180.173.99.59')
      allow_any_instance_of(ActionDispatch::Request).to receive(:host).and_return('commandp.com')
      enable_feature! :duncan
      get campaign_path(:duncan, locale: 'zh-TW'), CODE: 'shanghai'
      expect(response).to be_success
    end

    it 'render ok when feature flag duncan on and come from china except shanghai' do
      allow_any_instance_of(ActionDispatch::Request).to receive(:remote_ip).and_return('180.173.99.59')
      allow_any_instance_of(ActionDispatch::Request).to receive(:host).and_return('commandp.com')
      enable_feature! :duncan
      get campaign_path(:duncan, locale: 'zh-TW'), CODE: 'other'
      expect(response.code.to_i).to eq 302
    end
  end
end
