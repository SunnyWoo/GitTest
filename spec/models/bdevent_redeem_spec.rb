# == Schema Information
#
# Table name: bdevent_redeems
#
#  id                :integer          not null, primary key
#  code              :string(255)
#  bdevent_id        :integer
#  parent_id         :integer
#  children_count    :integer          default(0)
#  usage_count       :integer          default(0)
#  usage_count_limit :integer          default(-1)
#  product_model_ids :integer          default([]), is an Array
#  order_ids         :integer          default([]), is an Array
#  is_enabled        :boolean          default(TRUE)
#  created_at        :datetime
#  updated_at        :datetime
#  work_ids          :integer          default([]), is an Array
#

require 'rails_helper'

RSpec.describe BdeventRedeem, type: :model do
  it 'FactoryGirl' do
    expect(create(:bdevent_redeem)).to be_valid
  end

  it { should belong_to(:bdevent) }

  it 'cannot be used unless limit > count' do
    expect(create(:bdevent_redeem, usage_count: 0, usage_count_limit: 1).can_use?).to be(true)
    expect(create(:bdevent_redeem, usage_count: 1, usage_count_limit: 1).can_use?).to be(false)
  end

  it 'can be used if limit is -1' do
    expect(create(:bdevent_redeem, usage_count: 0, usage_count_limit: -1).can_use?).to be(true)
  end

  it 'create bdevent_redeem code upcase' do
    bdevent_redeem = create(:bdevent_redeem, code: 'abcde123')
    expect(bdevent_redeem.code).to eq 'ABCDE123'
  end

  context '#reach_limit?' do
    it 'returns false if bdevent_redeem is non-limited' do
      expect(create(:bdevent_redeem, usage_count_limit: -1)).not_to be_reach_limit
    end

    it 'returns false if bdevent_redeem is limited and usage count is not reach the limit' do
      expect(create(:bdevent_redeem, usage_count: 1, usage_count_limit: 5)).not_to be_reach_limit
    end

    it 'returns true if bdevent_redeem is limited and usage count is reach the limit' do
      expect(create(:bdevent_redeem, usage_count: 5, usage_count_limit: 5)).to be_reach_limit
    end
  end

  context 'bdevent_redeem used or not' do
    it 'not used' do
      bdevent_redeem = create(:bdevent_redeem)
      expect(bdevent_redeem.used?).to eq(false)
    end

    it 'used by the order' do
      bdevent_redeem = create(:used_bdevent_redeem)
      expect(bdevent_redeem.used?).to eq(true)
    end
  end

  it 'cannot creates event bdevent_redeem if quantity > 1' do
    expect(build(:bdevent_redeem, quantity: 2, usage_count_limit: -1)).to be_invalid
  end

  context 'after create' do
    context 'when quantity > 1' do
      it 'creates children that has the same bdevent_id' do
        bdevent_redeem = create(:bdevent_redeem, quantity: 5)
        bdevent_redeem.reload
        expect(bdevent_redeem.is_enabled?).to eq(false)
        expect(bdevent_redeem.children.size).to eq(5)
        bdevent_redeem.children.each do |child|
          expect(child.bdevent_id).to eq(bdevent_redeem.bdevent_id)
          expect(child.usage_count_limit).to eq(1)
          expect(child.product_model_ids).to eq(bdevent_redeem.product_model_ids)
        end
      end
    end
  end

  context 'is_enabled' do
    it 'set is_enabled true and check can_use? return true' do
      bdevent_redeem = create(:bdevent_redeem, is_enabled: true)
      expect(bdevent_redeem.can_use?).to eq(true)
    end

    it 'set is_enabled false and check can_use? return false' do
      bdevent_redeem = create(:bdevent_redeem, is_enabled: false)
      expect(bdevent_redeem.can_use?).to eq(false)
    end
  end

  context 'uniq code' do
    it 'raise error when same code' do
      code = 'samecode'
      expect(create(:bdevent_redeem, code: code)).to be_valid
      expect { create(:bdevent_redeem, code: code) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'raise error when same code, downcase & upcase' do
      expect(create(:bdevent_redeem, code: 'SAMECODE')).to be_valid
      expect { create(:bdevent_redeem, code: 'samecode') }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context '#increase_usage_count' do
    it 'when order_ids change' do
      bdevent_redeem = create(:bdevent_redeem)
      expect(bdevent_redeem.usage_count).to eq(0)
      bdevent_redeem.update order_ids: [create(:order).id]
      expect(bdevent_redeem.reload.usage_count).to eq(1)
    end
  end

  context "#works" do
    it 'return works' do
      work_id = create(:work).id
      bdevent_redeem = create(:bdevent_redeem, work_ids: [work_id])
      expect(bdevent_redeem.works.first.id).to eq(work_id)
    end
  end
end
