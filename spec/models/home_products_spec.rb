require 'spec_helper'

describe HomeProducts do
  describe '#ids' do
    context 'when redis is not stores any data' do
      it 'returns featured work ids' do
        work = create(:work, work_type: :is_public, featured: true)
        expect(HomeProducts.ids).to eq([work.id])
      end
    end

    context 'when redis is not stores a list' do
      it 'returns featured work ids' do
        HomeProducts.redis.set('ids', 'not a list')
        work = create(:work, work_type: :is_public, featured: true)
        expect(HomeProducts.ids).to eq([work.id])
      end
    end

    context 'when redis is stores a list' do
      it 'returns stored ids' do
        HomeProducts.ids = %w(1 2 3)
        work = create(:work, work_type: :is_public, featured: true)
        expect(HomeProducts.ids).to eq(%w(1 2 3))
      end
    end
  end
end
