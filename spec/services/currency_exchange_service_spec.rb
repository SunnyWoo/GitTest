require 'spec_helper'

describe CurrencyExchangeService do
  describe '#execute' do
    context 'with TWD currency' do
      before do
        create :usd_currency_type
        create :cny_currency_type
      end
      Then { CurrencyExchangeService.new(333, 'TWD', 'CNY').execute == 66.6 }
      And { CurrencyExchangeService.new(333, 'CNY', 'TWD').execute == 1665 }
      And { CurrencyExchangeService.new(300, 'TWD', 'USD').execute == 10 }
    end

    context 'with out TWD currency' do
      Then { expect { CurrencyExchangeService.new(333, 'CNY', 'CNY').execute }.to raise_error(CurrencyExchangeError) }
    end
  end
end
