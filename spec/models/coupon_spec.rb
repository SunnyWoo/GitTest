# == Schema Information
#
# Table name: coupons
#
#  id                       :integer          not null, primary key
#  title                    :string(255)
#  code                     :string(255)
#  expired_at               :date
#  created_at               :datetime
#  updated_at               :datetime
#  price_tier_id            :integer
#  parent_id                :integer
#  children_count           :integer          default(0)
#  discount_type            :string(255)
#  percentage               :decimal(8, 2)
#  condition                :string(255)
#  threshold_id             :integer
#  product_model_ids        :integer          default([]), is an Array
#  apply_target             :string(255)
#  usage_count              :integer          default(0)
#  usage_count_limit        :integer          default(-1)
#  begin_at                 :date
#  is_enabled               :boolean          default(TRUE)
#  auto_approve             :boolean          default(FALSE)
#  designer_ids             :integer          default([]), is an Array
#  work_gids                :text             default([]), is an Array
#  user_usage_count_limit   :integer          default(-1)
#  base_price_type          :string(255)
#  apply_count_limit        :integer
#  product_category_ids     :integer          default([]), is an Array
#  bdevent_id               :integer
#  settings                 :hstore           default({})
#  is_free_shipping         :boolean          default(FALSE)
#  is_not_include_promotion :boolean          default(FALSE)
#

require 'spec_helper'

describe Coupon do
  let(:user) { create(:user) }
  before { create_basic_currencies }

  context 'validation' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:base_price_type) }
    it { should validate_presence_of(:user_usage_count_limit) }
    it { should validate_inclusion_of(:discount_type).in_array(%w(fixed percentage pay none)) }
    it { should validate_inclusion_of(:condition).in_array(%w(none rules)) }
    it { should validate_inclusion_of(:base_price_type).in_array(%w(original special)) }
    context 'only allow 2 coupon_rules' do
      Given(:coupon) { build :coupon }
      When { 3.times { coupon.coupon_rules << build(:coupon_rule) } }
      When { coupon.valid? }
      Then { coupon.errors[:coupon_rules].first == I18n.t('errors.messages.too_long.other', count: 2) }
    end
  end

  it 'set code already' do
    coupon = create(:coupon, code: '123')
    expect(coupon).to be_valid
    expect(coupon.code).to match('123')
    expect(coupon.expired_at).to be_truthy
  end

  it 'check code not nil' do
    coupon = create(:coupon)
    expect(coupon.code).to be_truthy
    expect(coupon.can_use?(user)).to eq(true)
  end

  it 'cannot be used unless limit > count' do
    expect(create(:coupon, usage_count: 0, usage_count_limit: 1).can_use?(user)).to be(true)
    expect(create(:coupon, usage_count: 1, usage_count_limit: 1).can_use?(user)).to be(false)
  end

  it 'can be used if limit is -1' do
    expect(create(:coupon, usage_count: 0, usage_count_limit: -1).can_use?(user)).to be(true)
  end

  it 'create coupon code upcase' do
    coupon = create(:coupon, code: 'abcde123')
    expect(coupon.code).to eq 'ABCDE123'
  end

  describe '#reach_limit?' do
    it 'returns false if coupon is non-limited' do
      expect(create(:coupon, usage_count_limit: -1)).not_to be_reach_limit
    end

    it 'returns false if coupon is limited and usage count is not reach the limit' do
      expect(create(:coupon, usage_count: 1, usage_count_limit: 5)).not_to be_reach_limit
    end

    it 'returns true if coupon is limited and usage count is reach the limit' do
      expect(create(:coupon, usage_count: 5, usage_count_limit: 5)).to be_reach_limit
    end
  end

  context 'coupon used or not' do
    it 'not used' do
      coupon = create(:coupon)
      expect(coupon.used?).to eq(false)
    end

    it 'used by the order' do
      coupon = create(:used_coupon)
      expect(coupon.used?).to eq(true)
    end
  end

  it 'cannot creates event coupon if quantity > 1' do
    expect(build(:coupon, quantity: 2, usage_count_limit: -1)).to be_invalid
  end

  it 'cannot creates fixed coupon without price tier' do
    expect(build(:coupon, discount_type: 'fixed', price_tier: nil)).to be_invalid
  end

  it 'cannot creates percentage coupon with invalid percentage' do
    expect(build(:coupon, discount_type: 'percentage', percentage: 0)).to be_invalid
    expect(build(:coupon, discount_type: 'percentage', percentage: 1)).to be_valid
    expect(build(:coupon, discount_type: 'percentage', percentage: 1.01)).to be_invalid
    expect(build(:coupon, discount_type: 'percentage', percentage: nil)).to be_invalid
  end

  it 'cannot creates coupon if usage count > limit' do
    expect(build(:coupon, usage_count: 5, usage_count_limit: 3)).to be_invalid
  end

  it 'can creates coupon if limit is -1' do
    expect(build(:coupon, usage_count: 5, usage_count_limit: -1)).to be_valid
  end

  it 'cannot create coupon if begin day is before today' do
    expect(build(:coupon, begin_at: Date.yesterday)).to be_invalid
  end

  it 'cannot create coupon if expired day is before today' do
    expect(build(:coupon, expired_at: Date.yesterday)).to be_invalid
  end

  context 'after create' do
    context 'when quantity > 1' do
      it 'creates children that has the same title and price' do
        coupon = create(:coupon,
                        quantity: 5,
                        base_price_type: 'special',
                        apply_count_limit: 1,
                        user_usage_count_limit: 2,
                        is_free_shipping: true,
                        is_not_include_promotion: true)
        CreateUniqueCouponChildrenWorker.new.perform(coupon.id)
        coupon.reload
        expect(coupon.is_enabled?).to eq(false)
        expect(coupon.children.size).to eq(5)
        coupon.children.each do |child|
          expect(child.title).to eq(coupon.title)
          expect(child.usage_count_limit).to eq(1)
          expect(child.price_tier).to eq(coupon.price_tier)
          expect(child.discount_type).to eq(coupon.discount_type)
          expect(child.percentage).to eq(coupon.percentage)
          expect(child.condition).to eq(coupon.condition)
          expect(child.threshold).to eq(coupon.threshold)
          expect(child.product_model_ids).to eq(coupon.product_model_ids)
          expect(child.apply_target).to eq(coupon.apply_target)
          expect(child.begin_at).to eq(coupon.begin_at)
          expect(child.expired_at).to eq(coupon.expired_at)
          expect(child.base_price_type).to eq(coupon.base_price_type)
          expect(child.apply_count_limit).to eq(coupon.apply_count_limit)
          expect(child.user_usage_count_limit).to eq(coupon.user_usage_count_limit)
          expect(child.is_free_shipping).to eq(coupon.is_free_shipping)
          expect(child.is_not_include_promotion).to eq(coupon.is_not_include_promotion)
        end
      end
    end

    it 'sets default range' do
      coupon = create(:coupon, begin_at: nil, expired_at: nil)
      expect(coupon.begin_at).to be_present
      expect(coupon.expired_at).to be_present
    end
  end

  context 'after update' do
    context 'when quantity > 1' do
      it 'updates children' do
        coupon = create(:coupon, quantity: 5)
        CreateUniqueCouponChildrenWorker.new.perform(coupon.id)
        coupon.reload
        expect(coupon.children.size).to eq(5)
        coupon.update(title: 'new title')
        coupon.children.each do |child|
          expect(child.title).to eq('new title')
        end
      end
    end
  end

  context 'is_enabled' do
    it 'set is_enabled true and check can_use? return true' do
      coupon = create(:coupon, is_enabled: true)
      expect(coupon.can_use?(user)).to eq(true)
    end

    it 'set is_enabled false and check can_use? return false' do
      coupon = create(:coupon, is_enabled: false)
      expect(coupon.can_use?(user)).to eq(false)
    end
  end

  describe '.find_valid' do
    it 'returns coupon if found and can use' do
      coupon = create(:coupon)
      user = create(:user)
      expect(Coupon.find_valid(coupon.code, user)).to eq(coupon)
    end

    it 'raises error if code not found' do
      user = create(:user)
      expect { Coupon.find_valid('not exist', user) }.to raise_error(InvalidCouponError)
    end

    it 'raises error if code cannot be used' do
      coupon = create(:coupon, begin_at: Date.tomorrow)
      user = create(:user)
      expect { Coupon.find_valid(coupon.code, user) }.to raise_error(InvalidCouponError)
    end
  end

  describe 'uniq code' do
    it 'raise error when same code' do
      code = 'samecode'
      expect(create(:coupon, code: code)).to be_valid
      expect { create(:coupon, code: code) }.to raise_error
    end

    it 'raise error when same code, downcase & upcase' do
      expect(create(:coupon, code: 'SAMECODE')).to be_valid
      expect { create(:coupon, code: 'samecode') }.to raise_error
    end

    it 'allows same code for different available range' do
      create(:coupon, code: 'FUCK', begin_at: 5.days.from_now, expired_at: 10.days.from_now)
      expect(build(:coupon, code: 'FUCK', begin_at: 1.day.from_now, expired_at: 3.days.from_now)).to be_valid
      expect(build(:coupon, code: 'FUCK', begin_at: 11.days.from_now, expired_at: 13.days.from_now)).to be_valid
      expect(build(:coupon, code: 'FUCK', begin_at: 4.days.from_now, expired_at: 6.days.from_now)).to be_invalid
      expect(build(:coupon, code: 'FUCK', begin_at: 6.days.from_now, expired_at: 9.days.from_now)).to be_invalid
      expect(build(:coupon, code: 'FUCK', begin_at: 4.days.from_now, expired_at: 11.days.from_now)).to be_invalid
      expect(build(:coupon, code: 'FUCK', begin_at: 9.days.from_now, expired_at: 11.days.from_now)).to be_invalid
    end
  end

  describe '#create_unique_coupon_child' do
    it 'should give birth to a lovely own child' do
      coupon = create :coupon
      expect(coupon.children.size).to eq 0
      coupon.create_unique_coupon_child
      expect(coupon.children.size).to eq 1
      son_coupon = coupon.children.first
      expect(son_coupon.title).to eq coupon.title
      expect(son_coupon.usage_count_limit).to eq coupon.usage_count_limit
      expect(son_coupon.title).to eq coupon.title
      expect(son_coupon.discount_type).to eq coupon.discount_type
      expect(son_coupon.condition).to eq coupon.condition
    end

    it 'should not validate_begin_at_should_not_before_today' do
      coupon = create :coupon
      coupon.update_column :begin_at, Time.zone.yesterday
      coupon.create_unique_coupon_child
      expect(coupon.reload.children.count).to be > 0
    end
  end

  context '#expired_at_yesterday' do
    before do
      @coupon = create(:coupon)
      @expired_coupon = create(:coupon)
      @expired_coupon.update_attribute(:expired_at, Time.zone.yesterday)
    end

    it 'returns coupons' do
      expect(Coupon.expired_at_yesterday).to eq([@expired_coupon])
    end
  end

  context '#fallback_expired_coupon_orders' do
    before do
      @expired_coupon = create(:coupon)
      @order = create(:order, coupon: @expired_coupon)
      @expired_coupon.update_attribute(:expired_at, Time.zone.yesterday)
      @order.order_adjustments.create(source: @order.coupon,
                                      target: @order.base_price_type,
                                      event: 'apply', value: -100)
    end

    it 'execute' do
      expect(@order.coupon_id).to eq(@expired_coupon.id)
      Coupon.fallback_expired_coupon_orders
      expect(@order.reload.coupon_id).to be_nil
    end
  end

  context '#generate_code' do
    context 'when code_type is base' do
      let(:code_type) { 'base' }
      let(:regex) { /^[A-Z0-9]{6,20}$/ }
      it 'returns code' do
        expect(Coupon.generate_code(code_type)).to match(/[A-Z0-9]+/)
      end

      it 'returns code with length is 14' do
        length = 14
        code = Coupon.generate_code(code_type, length)
        expect(code).to match(regex)
        expect(code.size).to eq(length)
      end

      it 'raise error with length is 3' do
        length = 3
        expect{ Coupon.generate_code(code_type, length) }.to raise_error(ApplicationError)
      end

      it 'returns code after create' do
        length = 10
        coupon = create(:coupon, code_type: code_type, code_length: length)
        expect(coupon.code).to match(regex)
        expect(coupon.code.size).to match(length)
      end
    end

    context 'when code_type is number' do
      let(:code_type) { 'number' }
      let(:regex) { /^[0-9]{6,20}$/ }
      it 'returns code' do
        expect(Coupon.generate_code(code_type)).to match(regex)
      end

      it 'returns code with length is 10' do
        length = 10
        code = Coupon.generate_code(code_type, length)
        expect(code).to match(regex)
        expect(code.size).to eq(length)
      end

      it 'returns code with child' do
        length = 14
        coupon = create(:coupon, code_type: code_type, code_length: length, quantity: 5)
        coupon.children.each do |child|
          expect(child.code).to match(regex)
          expect(child.code.size).to match(length)
        end
      end
    end

    context 'when code_type is alphabet' do
      let(:code_type) { 'alphabet' }
      let(:regex) { /^[A-Z]{6,20}$/ }
      it 'returns code' do
        expect(Coupon.generate_code(code_type)).to match(regex)
      end

      it 'raise error with length is 30' do
        length = 30
        expect{ Coupon.generate_code(code_type, length) }.to raise_error(ApplicationError)
      end

      it 'returns code after create' do
        length = 12
        coupon = create(:coupon, code_type: code_type, code_length: length)
        expect(coupon.code).to match(regex)
        expect(coupon.code.size).to match(length)
      end
    end
  end

  context '#free_shipping?' do
    Given(:coupon) { create(:coupon, is_free_shipping: is_free_shipping) }
    context 'returns true' do
      Given(:is_free_shipping) { true }
      Then{ coupon.free_shipping? == true }
    end

    context 'returns false' do
      Given(:is_free_shipping) { false }
      Then{ coupon.free_shipping? == false }
    end
  end

  context 'retrieving rules' do
    Given(:product) { create :product_model }
    Given(:designer) { create :designer }
    Given(:item_rule) do
      create(:product_model_rule, product_model_ids: [product.id])
    end
    Given(:order_rule) do
      create(:threshold_rule, threshold_price_table: { "TWD" => 1_000, 'USD' => 33.0 })
    end

    Given(:coupon) { create :rule_coupon, apply_count_limit: 1, coupon_rules: [item_rule, order_rule] }

    Then { expect(coupon.item_rules).to match_array([item_rule]) }
    And { expect(coupon.order_rules).to match_array([order_rule]) }
  end

  describe '#affecting_item?' do
    Given(:coupon) { create(:coupon, condition: condition) }
    Given(:ans) { coupon.affecting_item? }
    context 'by condition' do
      context '= none' do
        Given(:condition) { 'none' }
        Then { expect(ans).to eq false }
      end

      context '= rules' do
        Given(:condition) { 'rules' }
        Given { coupon.coupon_rules = [rule] }
        context 'but ruled with threshold only' do
          Given(:rule) { create(:threshold_rule, threshold_price_table: { "TWD" => 1_000, 'USD' => 33.0 }) }
          Then { expect(ans).to eq false }
        end

        context 'ruled by other conditions' do
          Given(:product) { create :product_model }
          Given(:rule) { create(:product_model_rule, product_model_ids: [product.id]) }
          Then { expect(ans).to eq true }
        end
      end

      context '= simple' do
        Given(:condition) { 'simple' }
        Given { coupon.coupon_rules = [rule] }
        context 'but ruled with threshold only' do
          Given(:rule) { create(:threshold_rule, threshold_price_table: { "TWD" => 1_000, 'USD' => 33.0 }) }
          Then { expect(ans).to eq false }
        end

        context 'ruled by other conditions' do
          Given(:product) { create :product_model }
          Given(:rule) { create(:product_model_rule, product_model_ids: [product.id]) }
          Then { expect(ans).to eq true }
        end
      end
    end
  end

  describe '#discount_parameters' do
    Given(:coupon) { create(:coupon) }
    When(:parameters) { coupon.discount_parameters }
    Then { expect(parameters).to be_kind_of(Hash) }
    And { expect(parameters.keys).to match_array(%w(discount_type percentage price_tier_id)) }
  end

  context '#acts_as_adjustment_source' do
    it { is_expected.to have_many :adjustments }

    context '#source_name' do
      Given(:coupon) { create :coupon }
      When(:name) { coupon.source_name }
      Then { name == "#{coupon.class.name}: #{coupon.title}" }
    end
  end

  context 'cannot update expired_at when coupon is coming expired' do
    Given(:coupon) { create(:coupon, expired_at: Time.zone.today) }

    When { coupon.update(expired_at: Time.zone.today + 10.days) }
    Then { coupon.errors.key?(:expired_at) }
  end
end
