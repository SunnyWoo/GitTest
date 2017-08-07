# == Schema Information
#
# Table name: adjustments
#
#  id              :integer          not null, primary key
#  order_id        :integer
#  adjustable_id   :integer
#  adjustable_type :string(255)
#  source_id       :integer
#  source_type     :string(255)
#  value           :float            not null
#  description     :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  target          :integer
#  event           :integer          not null
#  quantity        :integer          default(1), not null
#

require 'spec_helper'

describe Adjustment, type: :model do
  it { should belong_to(:order).touch(true) }
  it { should belong_to(:adjustable) }
  it { should belong_to(:source) }
  it { should validate_presence_of(:event) }
  it { should define_enum_for(:event).with(Adjustment::EVENT_TYPES) }

  context 'factory_girl' do
    When(:adjustment) { build :adjustment }
    Then { adjustment.valid? }
  end

  describe '#deferred?' do
    context 'fallback' do
      Given(:adjustment) { build :adjustment, event: 'fallback' }
      Then { expect(adjustment).to be_deferred }
    end

    context 'supply' do
      Given(:adjustment) { build :adjustment, event: 'supply' }
      Then { expect(adjustment).to be_deferred }
    end

    context 'manual' do
      Given(:adjustment) { build :adjustment, event: 'manual' }
      Then { expect(adjustment).to be_deferred }
    end

    context 'apply' do
      Given(:adjustment) { build :adjustment, event: 'apply' }
      Then { expect(adjustment).not_to be_deferred }
    end
  end

  describe '#reason' do
    Given(:adjustment) { build :adjustment, event: event, target: 'special', source: source }
    Given(:reason) { adjustment.reason }

    context 'triggered by promotion' do
      Given(:source) { create :standardized_work_promotion }

      context 'in promotion' do
        Given(:event) { 'apply' }
        Then { expect(reason).to eq "In Promotion" }
      end

      context 'supply by starting new promotion' do
        Given(:event) { 'supply' }
        Then { expect(reason).to eq "Promotion Started" }
      end

      context 'fallback by ending of promotion' do
        Given(:event) { 'fallback' }
        Then { expect(reason).to eq "Promotion Had Ended" }
      end
    end

    context 'triggered by customer service' do
      Given(:source) { create :admin }

      context 'manual adjustment' do
        Given(:event) { 'manual' }
        Then { expect(reason).to eq "Customer Service" }
      end
    end
  end

  context '#discount' do
    before do
      Adjustment::EVENT_TYPES.each do |event|
        create(:adjustment, event: event)
      end
    end
    it 'returns adjustments' do
      expect(Adjustment.discount.count).to eq(2)
    end
  end

  context '#revert!' do
    it 'returns true' do
      adjustment = create(:adjustment)
      expect(adjustment.revert!).to be_truthy
      revert_adjustment = Adjustment.last
      expect(revert_adjustment.source).to eq(adjustment.source)
      expect(revert_adjustment.adjustable).to eq(adjustment.adjustable)
      expect(revert_adjustment.target).to eq(adjustment.target)
      expect(revert_adjustment.event).to eq('fallback')
      expect(revert_adjustment.value * -1).to eq(adjustment.value)
    end
  end

  describe '#reverted?' do
    context 'as new record' do
      Given(:adjustment) { build :adjustment }
      Then { expect(adjustment.reverted?).to eq false }
    end

    context 'as persisted record' do
      Given(:adjustment) { create :adjustment }
      Then { expect(adjustment.reverted?).to eq false }

      context 'had a fallback record which belongs to the same order, resource and adjustable' do
        Given do
          create :adjustment,
                 order: adjustment.order,
                 source: adjustment.source,
                 adjustable: adjustment.adjustable,
                 value: -adjustment.value,
                 event: :fallback
        end
        Then { expect(adjustment.reverted?).to eq true }
      end
    end
  end

  context 'methods of level determination' do
    Given(:order) { create :order, :priced }
    Given(:order_item) { order.order_items.first }
    describe '#item_level?' do
      context 'determined by type of adjustable' do
        context 'when it comes with order' do
          Given(:adjustment) { create :adjustment, adjustable: order }
          Then { expect(adjustment).not_to be_item_level }
        end

        context 'when it comes with order_item' do
          Given(:adjustment) { create :adjustment, adjustable: order_item }
          Then { expect(adjustment).to be_item_level }
        end
      end
    end

    describe '#order_level?' do
      context 'determined by type of adjustable' do
        context 'when it comes with order_item' do
          Given(:adjustment) { create :adjustment, adjustable: order_item }
          Then { expect(adjustment).not_to be_order_level }
        end

        context 'when it comes with order, needed to check on source further' do
          Given(:adjustment) { create :adjustment, adjustable: order, source: source }
          context 'source is a promotion for order price' do
            Given(:source) { create :promotion_for_order_price }
            Then { expect(adjustment).to be_order_level }
          end

          context 'source is a promotion for shipping_fee' do
            Given(:source) { create :promotion_for_shipping_fee }
            Then { expect(adjustment).not_to be_order_level }
          end
        end
      end
    end

    describe '#for_shipping_fee?' do
      context 'determined by type of adjustable' do
        context 'when it comes with order_item' do
          Given(:adjustment) { create :adjustment, adjustable: order_item }
          Then { expect(adjustment).not_to be_for_shipping_fee }
        end

        context 'when it comes with order, needed to check on source further' do
          Given(:adjustment) { create :adjustment, adjustable: order, source: source }
          context 'source is a promotion for order price' do
            Given(:source) { create :promotion_for_order_price }
            Then { expect(adjustment).not_to be_for_shipping_fee }
          end

          context 'source is a promotion for shipping_fee' do
            Given(:source) { create :promotion_for_shipping_fee }
            Then { expect(adjustment).to be_for_shipping_fee }
          end
        end
      end
    end
  end
end
