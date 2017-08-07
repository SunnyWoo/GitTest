# == Schema Information
#
# Table name: promotions
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :text
#  type            :string(255)      not null
#  aasm_state      :integer
#  rule            :integer
#  rule_parameters :json
#  targets         :integer
#  begins_at       :datetime
#  ends_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  level           :integer
#

require 'spec_helper'

describe Promotion, type: :model do
  it { should validate_presence_of :name }
  it { should validate_presence_of :type }
  it { should define_enum_for(:aasm_state).with(Promotion::AASM_STATES) }

  context 'validate_no_same_products' do
    Given(:promotion) { create(:product_model_promotion, begins_at: Time.zone.now.days_since(2)) }
    context '#overlapped_promotions' do
      Given!(:ready_promotion) { create(:product_model_promotion, aasm_state: 'ready', begins_at: Time.zone.now.days_since(3)) }
      Given!(:outdated_promotion) { create(:product_model_promotion, aasm_state: 'ready', begins_at: Time.zone.now.days_ago(1), ends_at: Time.zone.now.days_since(1)) }
      Given(:overlapped_promotions) { promotion.send(:overlapped_promotions) }
      context 'promotion ends_at null' do
        Then { overlapped_promotions.include?(ready_promotion) }
        And { overlapped_promotions.include?(outdated_promotion) == false }
      end
      context 'promotion ends_at has value' do
        Given(:promotion) { create(:product_model_promotion, begins_at: Time.zone.now.days_since(2), ends_at: Time.zone.now.days_since(5)) }
        Given!(:ready_promotion2) { create(:product_model_promotion, aasm_state: 'ready', begins_at: Time.zone.now.days_since(3), ends_at: Time.zone.now.days_since(4)) }
        Given!(:ready_promotion3) { create(:product_model_promotion, aasm_state: 'ready', begins_at: Time.zone.now.days_since(1), ends_at: Time.zone.now.days_since(7)) }
        Given!(:ready_promotion4) { create(:product_model_promotion, aasm_state: 'ready', begins_at: Time.zone.now.days_since(1), ends_at: Time.zone.now.days_since(3)) }
        Given!(:pending_promotion) { create(:product_model_promotion, aasm_state: 'pending', begins_at: Time.zone.now.days_since(3), ends_at: Time.zone.now.days_since(4)) }
        Then { overlapped_promotions.include?(ready_promotion) }
        And { overlapped_promotions.include?(ready_promotion2) }
        And { overlapped_promotions.include?(ready_promotion3) }
        And { overlapped_promotions.include?(ready_promotion4) }
        And { overlapped_promotions.exclude?(outdated_promotion) }
        And { overlapped_promotions.exclude?(pending_promotion) }
      end
    end

    context '#related_product_ids' do
      Given!(:product) { create :product_model }
      Given(:category) { create :product_category }
      Given!(:product2) { create :product_model, category: category }
      When do
        promotion.references.create(promotable: product)
        promotion.references.create(promotable: category)
      end
      Then { promotion.send(:related_product_ids) == [product.id, product2.id] }
    end

    context '#overlapped_product_ids' do
      Given!(:product_category) { create :product_category }
      Given!(:product) { create :product_model, category: product_category }
      Given!(:ready_promotion) { create(:product_model_promotion, aasm_state: 'ready', begins_at: Time.zone.now.days_since(3)) }
      When { ready_promotion.references.create(promotable: product_category) }
      Then { promotion.send(:overlapped_product_ids) == [product.id] }
    end

    context 'errors with same products' do
      Given!(:product) { create :product_model }
      before do
        promotion.references.create(promotable: product)
        expect(promotion).to receive(:overlapped_product_ids).and_return([product.id])
      end
      When { promotion.submit! }
      Then { promotion.errors.count > 0 }
      And { promotion.errors[:rules].include? I18n.t('errors.same_products_in_promotions', names: product.name) }
    end
  end

  context '.availabe' do
    let!(:standardized_work_promotion) { create :standardized_work_promotion, begins_at: 2.days.from_now, ends_at: 4.days.from_now }
    context 'within availabe session' do
      it 'includes the current promotion' do
        Timecop.freeze(3.days.from_now) do
          Promotion::ForStandardizedWork.available.include? standardized_work_promotion
        end
      end
    end

    context 'out of available session' do
      it 'excludes the outdated promotion' do
        Timecop.freeze(5.days.from_now) do
          Promotion::ForStandardizedWork.available.exclude? standardized_work_promotion
        end
      end
    end
  end

  describe '#supply!' do
    Given(:promotion) { create :standardized_work_promotion, begins_at: 2.days.from_now }
    Given(:o1) { create :order }
    Given(:o2) { create :order }
    Given(:o3) { create :order }
    Given(:o4) { create :order }
    Given(:o5) { create :order }

    Given do
      allow(promotion).to receive(:effecting_orders).and_return(orders)
      allow(promotion).to receive(:supply)
    end

    context 'retrieve related orders by calling #effecting_orders' do
      Given(:orders) { [o1, o2] }
      When { promotion.supply! }
      Then { expect(promotion).to have_received(:effecting_orders) }
      And { expect(promotion).to have_received(:supply).with(o1).exactly(1) }
      And { expect(promotion).to have_received(:supply).with(o2).exactly(1) }
    end

    context 'some orders were locked' do
      Given(:orders) { [o1, o2, o3, o4, o5] }
      Given do
        o1.locked!
        o3.locked!
      end
      When { promotion.supply! }

      context 'which should be supplied' do
        Then { expect(promotion).not_to have_received(:supply).with(o1) }
        And { expect(promotion).not_to have_received(:supply).with(o3) }
        And { expect(promotion).to have_received(:supply).with(o2).exactly(1) }
        And { expect(promotion).to have_received(:supply).with(o4).exactly(1) }
        And { expect(promotion).to have_received(:supply).with(o5).exactly(1) }
      end

      context 'which should be placed into to queue' do
        Given(:jobs) { Promotion::OrderUnlockedEventWorker.jobs }
        Then { expect(jobs.size).to eq 2 }
        And { expect(jobs[0]['args'][2]).to eq 'supply' }
        And { expect(jobs[1]['args'][2]).to eq 'supply' }
      end
    end
  end

  context '#rule_percentage=' do
    context 'percentage > 1 ' do
      Given(:promotion) { create :standardized_work_promotion }
      When { promotion.rule_percentage = 80 }
      Then { promotion.rule_percentage == 0.8 }
    end

    context 'percentage < 1 ' do
      Given(:promotion) { create :standardized_work_promotion }
      When { promotion.rule_percentage = 0.8 }
      Then { promotion.rule_percentage == 0.8 }
    end

    context 'percentage is string ' do
      Given(:promotion) { create :standardized_work_promotion }
      When { promotion.rule_percentage = '80' }
      Then { promotion.rule_percentage == 0.8 }
    end
  end

  context '#order_eligible' do
    context 'when promotion is order level' do
      context 'returns false without passing promotion applicable?' do
        Given(:promotion) { create :promotion_for_shipping_fee }
        Given(:order) { create :order }
        Given { promotion.stub(:applicable?).with(order).and_return(false) }
        Then { !promotion.order_eligible?(order) }
      end

      context 'returns true with passing promotion applicable?' do
        Given(:promotion) { create :promotion_for_shipping_fee }
        Given(:order) { create :order }
        Given { promotion.stub(:applicable?).with(order).and_return(true) }
        Then { promotion.order_eligible?(order) }
      end
    end

    context 'when promotion is not order_level' do
      context 'returns true with passing promotion applicable?' do
        Given(:promotion) { create :standardized_work_promotion }
        Given(:order) { create :order, :with_public_work }
        Given { promotion.stub(:applicable?).with(order.order_items.first).and_return(true) }
        When(:result) { promotion.order_eligible?(order) }
        Then { expect(result).to eq true }
      end

      context 'returns false without passing promotion applicable?' do
        Given(:promotion) { create :standardized_work_promotion }
        Given(:order) { create :order, :priced }
        Given { promotion.stub(:applicable?).with(order.order_items.first).and_return(false) }
        When(:result) { promotion.order_eligible?(order) }
        Then { expect(result).to eq false }
      end
    end
  end
end
