require 'spec_helper'

describe Pricing::ItemableDecorator do
  Given(:itemable) { create :work }
  Given(:decorator) { Pricing::ItemableDecorator.new(itemable) }

  describe '#original_prices' do
    context 'return a price' do
      When(:price) { decorator.original_prices }
      Then { expect(price).to be_kind_of(Price) }
    end

    context 'return the price with largest value' do
      Given {
        itemable.stub(:promotion_special_price).and_return(Price.new(123.0))
        itemable.stub(:promotion_original_price).and_return(Price.new(234.0))
      }
      When(:price) { decorator.original_prices }
      Then { expect(price.value).to eq 234.0 }
    end
  end

  describe '#prices' do
    context 'return a price' do
      When(:price) { decorator.prices }
      Then { expect(price).to be_kind_of(Price) }
    end

    context 'get prices via promotion_special_price' do
      Given { itemable.stub(:promotion_special_price).and_return(Price.new(876.0)) }
      When(:price) { decorator.prices }
      Then { expect(price.value).to eq 876.0 }
    end
  end
end
