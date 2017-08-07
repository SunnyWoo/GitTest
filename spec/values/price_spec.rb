require 'spec_helper'

describe Price do
  Given { create_basic_currencies }

  context 'initialized with scalar value' do
    context 'and default currency' do
      Given(:price) { Price.new(300) }

      describe '#value' do
        Then { expect(price.value).to eq 300.0 }
      end

      describe '#currency' do
        Then { expect(price.currency).to eq Price::DEFAULT_CURRENCY }
      end

      describe '#given_currencies' do
        Then { expect(price.given_currencies).to eq [Price::DEFAULT_CURRENCY] }
      end
    end

    context 'and specified currency' do
      Given(:price) { Price.new(300, 'TWD') }
      describe '#value' do
        Then { expect(price.value).to eq 300.0 }
      end

      describe '#currency' do
        Then { expect(price.currency).to eq 'TWD' }
      end

      describe '#[]' do
        Then { expect(price['USD']).to eq 10.0 }
        And { expect(price['TWD']).to eq 300.0 }
      end
    end
  end

  context 'initialized with prices hash' do
    Given(:hash) { { 'TWD' => 90.0, 'USD' => 2.99, 'CNY' => 17.66 } }
    context 'and default currency' do
      Given(:price) { Price.new(hash) }
      Then { expect(price.value).to eq hash[Price::DEFAULT_CURRENCY] }
      And { expect(price['USD']).to eq 2.99 }
    end

    context 'and specified currency' do
      Given(:price) { Price.new(hash, 'USD') }
      Then { expect(price.value).to eq 2.99 }

      context 'able to convert to other currency even wasnt given in hash' do
        When(:jpy) { price['JPY'].round(2) }
        Then { expect(jpy).to eq 332.0 } # from USD to JPY
      end
    end

    describe '#given_currencies' do
      Given(:price) { Price.new(hash) }
      Then { expect(price.given_currencies).to eq %w(TWD USD CNY) }
    end
  end

  context 'math operations' do
    describe '+' do
      Given(:p1) { Price.new(30.0) }
      Given(:p2) { Price.new(90.0) }
      context 'the addend is a price also' do
        When(:ans) { p1 + p2 }
        Then { expect(ans).to be_kind_of Price }
        And { expect(ans.value).to eq 120.0 }
      end

      context 'it allow the addend to be a scalar value' do
        When(:ans) { p1 + 14 }
        Then { expect(ans.value).to eq 44 }
      end

      context 'added with different currency it kept currency of summand' do
        Given(:summand) { Price.new(13.0, 'USD') }
        Given(:added) { Price.new(300.0, 'TWD') }
        When(:ans) { summand + added }
        Then { expect(ans.currency).to eq 'USD' }
        And { expect(ans.value).to eq 23.0 }
      end
    end

    describe '-' do
      Given(:p1) { Price.new(960.0) }
      Given(:p2) { Price.new(90.0) }
      When(:ans) { p1 - p2 }
      Then { expect(ans).to be_kind_of Price }
      And { expect(ans.value).to eq 870.0 }
    end

    describe '*' do
      Given(:p1) { Price.new(10.0) }
      When(:ans) { p1 * 10.5 }
      Then { expect(ans.value).to eq 105.0 }
    end

    describe '/' do
      Given(:p1) { Price.new(1050.0) }
      When(:ans) { p1 / 10.5 }
      Then { expect(ans.value).to eq 100.0 }
    end
  end

  context 'comparision' do
    describe '==' do
      context 'same initializer' do
        Given(:p1) { Price.new(1050.0, 'TWD') }
        Given(:p2) { Price.new(1050.0, 'TWD') }
        Then { expect(p1).to eq p2 }
      end

      context 'differnt initializer but had same value in default currency' do
        Given(:p1) { Price.new(1050.0, 'TWD') }
        Given(:p2) { Price.new('TWD' => 1050.0, 'USD' => 35.0) }
        Then { expect(p1).to eq p2 }
      end
    end

    describe '>' do
      Given(:p1) { Price.new(1050.0, 'TWD') }
      Given(:p2) { Price.new(250.0, 'TWD') }
      When(:ans) { p1 > p2 }
      Then { expect(ans).to be_truthy }
    end
  end

  describe '#with_currency' do
    Given(:price) { Price.new(900, 'TWD') }
    When(:new_price) { price.with_currency('USD') }
    Then { expect(new_price.currency).to eq 'USD' }
    And { expect(new_price.value).to eq 30.0 }
    And { expect(new_price.object_id).not_to eq price.object_id }
  end

  describe '#with_currency!' do
    Given(:price) { Price.new(900, 'TWD') }
    When(:new_price) { price.with_currency!('USD') }
    Then { expect(new_price.currency).to eq 'USD' }
    And { expect(new_price.value).to eq 30.0 }
    And { expect(new_price.object_id).to eq price.object_id }
  end

  describe '#in_currency' do
    Given(:price) { Price.new('TWD' => 1001) }
    Then { expect(price['USD']).to eq 33.37 }
    And { expect(price['JPY']).to eq 3707 }
  end
end
