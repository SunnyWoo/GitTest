shared_examples 'has promotion price' do
  before { subject.flush_cached_promotion_prices }
  after { subject.flush_cached_promotion_prices }

  context 'respond to required methods' do
    Then { expect(subject).to respond_to(:prices) }
    And { expect(subject).to respond_to(:special_prices) }
    And { expect(subject).to respond_to(:original_prices) }
    And { expect(subject).to respond_to(:active_promotions) }
  end

  describe '#promotion_special_price' do
    context 'return value by called #cache_promotion_price' do
      Given { subject.stub(:cache_promotion_price).and_return('foo') }
      When(:ans) { subject.promotion_special_price }
      Then { expect(ans).to eq 'foo' }
      And { expect(subject).to have_received(:cache_promotion_price) }
    end
  end

  describe '#promotion_original_price' do
    context 'equals to original_prices' do
      When(:ans) { subject.promotion_original_price }
      Then { expect(ans).to eq Price.new(subject.original_prices) }
    end
  end

  describe '#cache_promotion_price' do
    Given do
      subject.stub(:active_promotions).and_return(active_promotions)
      subject.stub(:special_prices).and_return('TWD' => 599.0)
      subject.stub(:original_prices).and_return('TWD' => 799.0)
    end
    Given(:p1) { create :standardized_work_promotion }
    Given(:p2) { create :standardized_work_promotion, :percentage }
    Given(:p3) { create :standardized_work_promotion }

    context 'no active promotions' do
      Given(:active_promotions) { [] }
      When(:price) { subject.cache_promotion_price }
      Then { expect(price.value).to eq 599.0 }
    end

    context 'choose promotion with target' do
      context 'one active promotion matched' do
        Given(:active_promotions) { [p3] }
        Given do
          p3.stub(:fetch_promotion_price).with(subject).and_return(Price.new(199.0))
        end
        When(:price) { subject.cache_promotion_price }
        Then { expect(price.value).to eq 199.0 }
      end

      context 'multiple active promotion matched, pick the lowest price' do
        Given(:active_promotions) { [p1, p3] }
        Given do
          p1.stub(:fetch_promotion_price).with(subject).and_return(Price.new(299.0))
          p3.stub(:fetch_promotion_price).with(subject).and_return(Price.new(159.0))
        end
        When(:price) { subject.cache_promotion_price }
        Then { expect(price.value).to eq 159.0 } # TWD -300
      end
    end

    context 'should cached promotion price' do
      Given(:active_promotions) { [p1] }
      Given { subject.stub(:fetch_current_promotion_and_price).and_return([p1, Price.new(1399.0)]) }
      When {
        subject.promotion_special_price
        subject.promotion_special_price
      }
      Then {
        receive_count = subject.id.present? ? 1 : 2
        expect(subject).to have_received(:fetch_current_promotion_and_price).exactly(receive_count)
      }
    end
  end
end
