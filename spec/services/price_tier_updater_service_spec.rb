require 'spec_helper'

describe PriceTierUpdaterService do
  subject(:service) { PriceTierUpdaterService.new(changeset) }

  before do
    CurrencyType.where(code: 'TWD').first_or_create
    CurrencyType.where(code: 'USD').first_or_create
  end

  describe '#save' do
    context 'when changeset is nil' do
      let(:changeset) { nil }
      it 'should be ok' do
        service.save
      end
    end

    context 'contains method create' do
      let(:changeset) do
        {
          '0' => {'method' => 'create',
                  'tier' => {'tier' => 1, 'USD' => 50, 'TWD' => 50, 'cid' => 'cid1'}}
        }
      end

      it 'creates price tier by given tier data' do
        service.save
        expect(PriceTier.count).to eq(1)
        pt = PriceTier.last
        expect(pt.tier).to eq(1)
        expect(pt.prices).to eq('USD' => 50, 'TWD' => 50)
      end
    end

    context 'contains many creates' do
      let(:changeset) do
        {
          '0' => {'method' => 'create',
                  'tier' => {'tier' => 1, 'USD' => 50, 'TWD' => 50, 'cid' => 'cid1'}},
          '1' => {'method' => 'create',
                  'tier' => {'tier' => 2, 'USD' => 100, 'TWD' => 100, 'cid' => 'cid2'}},
          '2' => {'method' => 'create',
                  'tier' => {'tier' => 3, 'USD' => 150, 'TWD' => 150, 'cid' => 'cid3'}}
        }
      end

      it 'creates price tier by given tier data' do
        service.save
        expect(PriceTier.count).to eq(3)
        pt = PriceTier.last
        expect(pt.tier).to eq(3)
        expect(pt.prices).to eq('USD' => 150, 'TWD' => 150)
      end
    end

    context 'contains method update with id' do
      let(:price_tier) { create(:price_tier) }
      let(:changeset) do
        {
          '0' => {'method' => 'update',
                  'tier' => {'tier' => 1, 'USD' => 50, 'TWD' => 50, 'id' => price_tier.id}}
        }
      end

      it 'updates price tier by given tier data' do
        service.save
        expect(PriceTier.count).to eq(1)
        pt = PriceTier.last
        expect(pt.tier).to eq(1)
        expect(pt.prices).to eq('USD' => 50, 'TWD' => 50)
      end
    end

    context 'contains method update with cid' do
      let(:changeset) do
        {
          '0' => {'method' => 'create',
                  'tier' => {'tier' => 1, 'USD' => 10, 'TWD' => 10, 'cid' => 'cid1'}},
          '1' => {'method' => 'update',
                  'tier' => {'tier' => 1, 'USD' => 50, 'TWD' => 50, 'cid' => 'cid1'}}
        }
      end

      it 'updates price tier by given tier data' do
        service.save
        expect(PriceTier.count).to eq(1)
        pt = PriceTier.last
        expect(pt.tier).to eq(1)
        expect(pt.prices).to eq('USD' => 50, 'TWD' => 50)
      end
    end

    context 'after update' do
      let(:changeset) { {} }

      it 'retiers all price tier' do
        create(:price_tier, tier: 2)
        create(:price_tier, tier: 3)
        create(:price_tier, tier: 5)
        service.save
        expect(PriceTier.order(:tier).pluck(:tier)).to eq([1, 2, 3])
      end
    end
  end
end
