require 'spec_helper'

describe Admin::PromotionForm do
  context 'validations' do
    context 'presence_of name' do
      Given(:promotion) { build :promotion_for_shipping_fee }
      Given(:form) { Admin::PromotionForm.new(promotion) }
      When { form.attributes = { name: '' } }
      Then { expect(form.valid?).to eq false }
    end

    context 'presence_of type' do
      Given(:promotion) { build :promotion, type: '', begins_at: nil }
      Given(:form) { Admin::PromotionForm.new(promotion) }
      When { form.attributes = { name: 'foo' } }
      Then { expect(form.valid?).to eq false }
      And { expect(form.errors[:type]).to be_present }
    end

    context 'presence_of begins_at' do
      Given(:promotion) { build :promotion_for_shipping_fee, begins_at: nil }
      Given(:form) { Admin::PromotionForm.new(promotion) }
      When { form.attributes = { name: 'bar' } }
      Then { expect(form.valid?).to eq false }
      And { expect(form.errors[:begins_at]).to be_present }
    end

    context 'validate_rule_discount_type' do
      context 'with type is Promotion::ForProductCategory or Promotion::ForProductModel' do
        Given!(:promotion) { create :promotion, name: 'name', rule_parameters: {}, type: %w(Promotion::ForProductCategory Promotion::ForProductModel).sample }
        Given(:form) { Admin::PromotionForm.new(promotion) }
        When { form.attributes = { name: 'bar' } }
        Then { expect(form.valid?).to eq false }
        And { expect(form.errors[:rule_discount_type]).to be_present }
      end

      context 'with type is Promotion::ForShippingFee or Promotion::ForItemablePrice' do
        Given!(:promotion) { create :promotion, name: 'name', rule_parameters: {}, type: %w(Promotion::ForShippingFee Promotion::ForItemablePrice).sample }
        Given(:form) { Admin::PromotionForm.new(promotion) }
        When { form.attributes = { name: 'bar' } }
        Then { expect(form.valid?).to eq true }
      end
    end

    context 'validate_beigns_at_should_not_be_in_an_hour' do
      context 'with begins_at > 1.hour.from_now' do
        Given(:standardized_work_promotion) { build :standardized_work_promotion, begins_at: 2.days.from_now }
        Given(:promotion_form) { Admin::PromotionForm.new(standardized_work_promotion) }
        Then { promotion_form.valid? }
      end

      context 'with begins_at < 1.hour.from_now' do
        Given(:standardized_work_promotion) { build :standardized_work_promotion, begins_at: 5.minutes.from_now }
        Given(:promotion_form) { Admin::PromotionForm.new(standardized_work_promotion) }
        Then { promotion_form.invalid? }
      end
    end

    context 'validate_begins_at_should_not_be_later_than_ends_at' do
      context 'with begins_at < ends_at' do
        Given(:standardized_work_promotion) { build :standardized_work_promotion, begins_at: 2.days.from_now, ends_at: 4.days.from_now }
        Given(:promotion_form) { Admin::PromotionForm.new(standardized_work_promotion) }
        Then { promotion_form.valid? }
      end

      context 'with begins_at > ends_at' do
        Given(:standardized_work_promotion) { build :standardized_work_promotion, begins_at: 2.days.from_now, ends_at: 1.day.from_now }
        Given(:promotion_form) { Admin::PromotionForm.new(standardized_work_promotion) }
        Then { promotion_form.invalid? }
      end
    end
  end

  context 'creation' do
    Given(:form) { Admin::PromotionForm.new(promotion) }
    Given(:promotion) { Promotion.new }
    Given(:last_promotion) { Promotion.last }
    Given(:begins_at) { Time.zone.now.days_since(3) }
    Given(:ends_at) { begins_at.months_since(2) }
    Given(:attrs) do
      {
        name: 'foo', description: 'bar',
        type: 'Promotion::ForShippingFee',
        begins_at: begins_at.to_s, ends_at: ends_at.to_s
      }
    end
    When(:result) do
      form.attributes = attrs
      form.save
    end
    Then { expect(result).to eq true }
    And { expect(promotion).to exist_in_database }
    And { expect(last_promotion).to be_kind_of(Promotion::ForShippingFee) }
    And { expect(last_promotion.name).to eq 'foo' }
    And { expect(last_promotion.description).to eq 'bar' }
    And { expect(last_promotion.begins_at.to_s).to eq begins_at.to_s }
    And { expect(last_promotion.ends_at.to_s).to eq ends_at.to_s }
  end

  context 'edit' do
    Given(:form) { Admin::PromotionForm.new(promotion) }
    context '#save' do
      context 'for_itemable_price' do
        Given(:promotion) { create :promotion_for_itemable_price }
        Given(:tier1) { create :price_tier }
        Given(:tier2) { create :price_tier }
        Given(:tier3) { create :price_tier }
        Given(:standardized_work) { create :standardized_work }
        Given(:product) { create :product_model }
        Given(:category) { create :product_category }

        When(:result) do
          form.attributes = params
          form.save
        end

        context 'update basic fields' do
          Given(:params) do
            {
              name: 'new name',
              description: 'new description'
            }
          end
          Then { expect(result).to eq true }
          And { expect(promotion.name).to eq "new name" }
          And { expect(promotion.description).to eq 'new description' }
        end

        context 'add references' do
          Given(:params) do
            {
              promotion_references: {
                gid1: { promotable_id: standardized_work.id, promotable_type: 'StandardizedWork', price_tier_id: tier1.id },
                gid2: { promotable_id: product.id, promotable_type: 'ProductModel', price_tier_id: tier2.id },
                gid3: { promotable_id: category.id, promotable_type: 'ProductCategory', price_tier_id: tier3.id }
              }
            }
          end
          Then { expect(result).to eq true }
          And { expect(promotion.references.count).to eq 3 }
        end

        context 'upsert or destroy references' do
          Given!(:ref1) { promotion.references.create!(promotable: standardized_work, price_tier: tier1 ) }
          Given!(:ref2) { promotion.references.create!(promotable: product, price_tier: tier2 ) }
          Given(:params) do
            {
              promotion_references: {
                gid1: { id: ref1.id, promotable_id: standardized_work.id, promotable_type: 'StandardizedWork', price_tier_id: tier3.id },
                gid2: { id: ref2.id.to_s, _destroy: "1", promotable_id: product.id, promotable_type: 'ProductModel', price_tier_id: tier2.id },
                gid3: { id: '', promotable_id: category.id, promotable_type: 'ProductCategory', price_tier_id: tier1.id }
              }
            }
          end
          Given(:new_ref) { promotion.references.detect { |r| r.promotable == category } }
          Then { expect(result).to eq true }
          And { expect(promotion.reload.references.count).to eq 2 }
          And { expect(ref2).not_to exist_in_database }
          And { expect(ref1.reload.price_tier).to eq tier3 }
          And { expect(new_ref.price_tier).to eq tier1 }
        end
      end

      context 'for_shipping_fee' do
        Given(:promotion) { create :promotion_for_shipping_fee_pured }
        Given(:price_tier) { create :price_tier, :twd_499 }
        When(:result) do
          form.attributes = params
          form.save
        end

        context 'add references' do
          Given(:params) do
            {
              rules: {
                '0' => { condition: 'threshold', threshold_id: price_tier.id },
                '1' => { condition: 'include_product_models', product_model_ids: [1, 2, 3] },
              }
            }
          end
          Given(:rule1) { promotion.rules[0] }
          Given(:rule2) { promotion.rules[1] }
          Then { expect(result).to eq true }
          And { expect(promotion.rules.count).to eq 2 }
          And { expect(rule1.condition).to eq 'threshold' }
          And { expect(rule1.threshold).to eq price_tier }
          And { expect(rule2.condition).to eq 'include_product_models' }
          And { expect(rule2.product_model_ids).to eq [1, 2, 3] }
        end

        context 'upsert or destroy references' do
          Given!(:rule1) { promotion.rules.create!(condition: 'threshold', threshold: price_tier) }
          Given!(:rule2) { promotion.rules.create!(condition: 'include_product_models', product_model_ids: [6, 7, 8, 9]) }
          Given(:params) do
            {
              rules: {
                '0' => { id: rule1.id.to_s, _destroy: '1', condition: 'threshold', threshold_id: price_tier.id },
                '1' => { id: rule2.id, condition: 'include_product_models', product_model_ids: [1, 2, 3] },
                '2' => { id: '', condition: 'include_designers', designer_ids: [24, 25, 27] }
              }
            }
          end
          Given(:new_rule) { promotion.rules.detect(&:include_designers?) }
          Then { expect(result).to eq true }
          And { expect(promotion.reload.rules.count).to eq 2 }
          And { expect(rule1).not_to exist_in_database }
          And { expect(rule2.reload.product_model_ids).to eq [1, 2, 3] }
          And { expect(new_rule.designer_ids).to eq [24, 25, 27] }
        end
      end
    end
  end
end
