require 'spec_helper'

describe Order::PromotionsProxy do
  Given(:current) { Time.zone.now }
  Given!(:p1) { create :standardized_work_promotion, ends_at: current.days_since(10) }
  Given!(:p2) { create :standardized_work_promotion, ends_at: current.days_since(5) }
  Given!(:p3) { create :standardized_work_promotion, ends_at: current.days_since(8) }
  Given!(:p4) { create :standardized_work_promotion, ends_at: nil }

  describe '.build' do
    Given(:order) { create :order }
    Given!(:a1) { create :adjustment, :apply, order: order, source: p1 }
    Given!(:a2) { create :adjustment, :apply, order: order, source: p2 }
    Given!(:a3) { create :adjustment, :manual, order: order, source: Admin.first }
    Given!(:a4) { create :adjustment, :fallback, order: order, source: p1 }

    When(:proxy) { Order::PromotionsProxy.build(order) }
    Then { expect(proxy.to_a).to eq([p1, p2]) }
  end

  describe 'recent_ending' do
    context 'should sort by recently ending' do
      Given {
        p1.stub(:started?).and_return(true)
        p2.stub(:started?).and_return(true)
        p3.stub(:started?).and_return(true)
      }
      When(:proxy) { Order::PromotionsProxy.new([p1, p2, p3]) }
      Then { expect(proxy.recent_ending.to_a).to eq [p2, p3, p1] }
    end

    context 'should excluded promotion does not start' do
      Given {
        p1.stub(:started?).and_return(true)
        p2.stub(:started?).and_return(true)
        p3.stub(:started?).and_return(false)
      }
      When(:proxy) { Order::PromotionsProxy.new([p1, p2, p3]) }
      Then { expect(proxy.recent_ending.to_a).to eq [p2, p1] }
    end

    context 'should excluded promotion ends_at is nil' do
      Given {
        p1.stub(:started?).and_return(true)
        p4.stub(:started?).and_return(true)
      }
      When(:proxy) { Order::PromotionsProxy.new([p1, p4]) }
      Then { expect(proxy.recent_ending.to_a).to eq [p1] }
    end
  end
end
