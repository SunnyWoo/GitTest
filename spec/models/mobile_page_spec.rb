# == Schema Information
#
# Table name: mobile_pages
#
#  id           :integer          not null, primary key
#  key          :string(255)
#  title        :string(255)
#  begin_at     :datetime
#  close_at     :datetime
#  is_enabled   :boolean          default(FALSE)
#  contents     :json
#  created_at   :datetime
#  updated_at   :datetime
#  page_type    :integer
#  country_code :string(255)
#

require 'rails_helper'

RSpec.describe MobilePage, type: :model do
  it 'FactoryGirl' do
    expect(build(:mobile_page)).to be_valid
  end

  context 'when validating page_type homepage, one country_code only once' do
    it 'returns valid with country_code is TW' do
      expect(create(:mobile_page, page_type: :homepage, country_code: 'TW')).to be_valid
      expect { create(:mobile_page, page_type: :homepage, country_code: 'TW') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'returns valid with country_code is JP' do
      expect(create(:mobile_page, page_type: :homepage, country_code: 'JP')).to be_valid
      expect { create(:mobile_page, page_type: :homepage, country_code: 'JP') }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context '#country_code' do
    it 'returns true when country_code include MobilePage::COUNTRY_CODES' do
      expect(build(:mobile_page, country_code: 'TW')).to be_valid
    end

    it 'returns false when country_code not include MobilePage::COUNTRY_CODES' do
      expect(build(:mobile_page, country_code: 'KO')).not_to be_valid
    end
  end

  context 'when validating key, unique scope on country_code' do
    it 'returns valid with country_code is TW' do
      expect(create(:mobile_page, key: :home, country_code: 'TW')).to be_valid
      expect { create(:mobile_page, key: :home, country_code: 'TW') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'returns valid with country_code is JP' do
      expect(create(:mobile_page, key: :home, country_code: 'JP')).to be_valid
      expect { create(:mobile_page, key: :home, country_code: 'JP') }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context '#mapping_country_code' do
    context 'region is china' do
      before { stub_env('REGION', 'china') }

      it 'returns CN when country_code is TW' do
        expect(MobilePage.mapping_country_code('TW')).to eq('CN')
      end

      it 'returns CN when country_code is CN' do
        expect(MobilePage.mapping_country_code('CN')).to eq('CN')
      end

      it 'returns CN when country_code is JP' do
        expect(MobilePage.mapping_country_code('JP')).to eq('CN')
      end
    end

    context 'region is global' do
      context 'returns TW' do
        before { stub_env('REGION', 'global') }
        let(:country_code) { 'TW' }

        it 'when country_code is MO' do
          expect(MobilePage.mapping_country_code('MO')).to eq(country_code)
        end

        it 'when country_code is HK' do
          expect(MobilePage.mapping_country_code('HK')).to eq(country_code)
        end

        it 'when country_code is TW' do
          expect(MobilePage.mapping_country_code('TW')).to eq(country_code)
        end
      end

      context 'returns JP' do
        let(:country_code) { 'JP' }

        it 'returns JP when country_code is JP' do
          expect(MobilePage.mapping_country_code('JP')).to eq(country_code)
        end
      end

      context 'returns EN' do
        let(:country_code) { 'EN' }

        it 'returns EN when country_code is EN' do
          expect(MobilePage.mapping_country_code('EN')).to eq(country_code)
        end

        it 'returns EN when country_code is KR' do
          expect(MobilePage.mapping_country_code('KR')).to eq(country_code)
        end

        it 'returns EN when country_code is MY' do
          expect(MobilePage.mapping_country_code('MY')).to eq(country_code)
        end
      end
    end
  end
end
