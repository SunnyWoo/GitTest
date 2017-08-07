require 'spec_helper'

describe CurrentCurrencyCode do
  class StubController < ActionController::Base
    include CurrentCurrencyCode
    def client_ip
      remote_ip
    end
  end

  let(:controller) { StubController.new }

  describe '#current_currency_code' do
    context 'When ENV REGION: china' do
      Given { stub_env('REGION', 'china') }
      context 'And Ip in US' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('127.0.0.1') }
        Then { controller.current_currency_code == 'CNY' }
      end

      context 'And Ip in TW' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('202.39.253.11') }
        Then { controller.current_currency_code == 'CNY' }
      end

      context 'And Ip in JP' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('202.248.110.243') }
        Then { controller.current_currency_code == 'CNY' }
      end

      context 'And Ip in HK' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('223.19.212.121') }
        Then { controller.current_currency_code == 'CNY' }
      end

      context 'And Ip in CN' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('120.198.231.22') }
        Then { controller.current_currency_code == 'CNY' }
      end
    end

    context 'When ENV REGION: global' do
      Given { stub_env('REGION', 'global') }

      context 'And Ip in US' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('127.0.0.1') }
        Then { controller.current_currency_code == 'USD' }
      end

      context 'And Ip in TW' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('202.39.253.11') }
        Then { controller.current_currency_code == 'TWD' }
      end

      context 'And Ip in JP' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('202.248.110.243') }
        Then { controller.current_currency_code == 'JPY' }
      end

      context 'And Ip in HK' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('223.19.212.121') }
        Then { controller.current_currency_code == 'HKD' }
      end

      context 'And Ip in CN' do
        Given { allow_any_instance_of(StubController).to receive(:remote_ip).and_return('120.198.231.22') }
        Then { controller.current_currency_code == 'CNY' }
      end
    end
  end
end
