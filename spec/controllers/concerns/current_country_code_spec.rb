require 'spec_helper'

describe CurrentCountryCode do
  class StubController < ActionController::Base
    include CurrentCountryCode
  end

  let(:controller) { StubController.new }

  describe '#country_code_by_ip' do
    it 'returns correct country code' do
      expect(controller.country_code_by_ip('202.39.253.11')).to eq('TW')
      expect(controller.country_code_by_ip('202.248.110.243')).to eq('JP')
    end

    it 'returns US by default if ip is undetectable' do
      expect(controller.country_code_by_ip('127.0.0.1')).to eq('US')
    end
  end
end
