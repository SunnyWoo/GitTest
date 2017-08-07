require 'spec_helper'

describe Admin::BillingProfileForm do
  Given(:form) { Admin::BillingProfileForm.new(profile, type: type) }
  Given(:type) { nil }
  Given(:profile) { create :billing_profile, country_code: country_code }
  Given(:country_code) { 'TW' }

  context 'china' do
    Given(:country_code) { 'CN' }
    context 'legacy version, without address data' do
      describe '#with_province?' do
        Then { expect(form.with_province?).to eq false }
      end

      describe '#with_district?' do
        Then { expect(form.with_district?).to eq false }
      end

      describe '#support_city_option?' do
        Then { expect(form.support_city_option?).to eq false }
      end
    end

    context 'new version with address data' do
      Given(:address) { Address.new(province_id: 3) }
      before do
        allow(address).to receive(:dist_code).and_return('110192')
        allow(profile).to receive(:address_data).and_return(address)
      end
      describe '#with_province?' do
        Then { expect(form.with_province?).to eq true }
      end

      describe '#with_district?' do
        Then { expect(form.with_district?).to eq true }
      end

      describe '#support_city_option?' do
        Then { expect(form.support_city_option?).to eq true }
      end
    end

    context 'country_changed is true' do
      Given(:form) { Admin::BillingProfileForm.new(profile, country_changed: true) }
      describe '#with_province?' do
        Then { expect(form.with_province?).to eq true }
      end

      describe '#with_district?' do
        Then { expect(form.with_district?).to eq true }
      end

      describe '#support_city_option?' do
        Then { expect(form.support_city_option?).to eq true }
      end
    end
  end

  context 'taiwan' do
    Given(:country_code) { 'TW' }
    context 'legacy version, without address data' do
      describe '#with_province?' do
        Then { expect(form.with_province?).to eq false }
      end

      describe '#with_district?' do
        Then { expect(form.with_district?).to eq false }
      end

      describe '#support_city_option?' do
        Then { expect(form.support_city_option?).to eq false }
      end
    end

    context 'new version with address data' do
      Given { profile.address_data = Address.new(province_id: 3, dist_code: '112') }
      describe '#with_province?' do
        Then { expect(form.with_province?).to eq false }
      end

      describe '#with_district?' do
        Then { expect(form.with_district?).to eq true }
      end

      describe '#support_city_option?' do
        Then { expect(form.support_city_option?).to eq true }
      end
    end

    context 'country_changed is true' do
      Given(:form) { Admin::BillingProfileForm.new(profile, country_changed: true) }
      describe '#with_province?' do
        Then { expect(form.with_province?).to eq false }
      end

      describe '#with_district?' do
        Then { expect(form.with_district?).to eq true }
      end

      describe '#support_city_option?' do
        Then { expect(form.support_city_option?).to eq true }
      end
    end
  end

  describe '#save' do
    context 'address' do
      context 'with legacy format' do
        Given(:attributes) do
          {
            city: 'Taipei',
            state: 'CA',
            address: 'abc',
            country_code: 'TW',
            zip_code: '119'
          }
        end
        When do
          form.attributes = attributes
          form.save
          profile.reload
        end
        Given(:data) { profile.address_data }
        Then { expect(profile).to be_persisted }
        And { expect(profile.city).to eq 'Taipei' }
        And { expect(profile.state).to eq 'CA' }
        And { expect(profile.address).to eq 'abc' }
        And { expect(profile.country_code).to eq 'TW' }
        And { expect(profile.zip_code).to eq '119' }
        And { expect(data.city).to eq 'Taipei' }
        And { expect(data.state).to eq 'CA' }
        And { expect(data.address).to eq 'abc' }
        And { expect(data.country_code).to eq 'TW' }
        And { expect(data.zip_code).to eq '119' }
      end

      context 'with new format' do
        Given(:attributes) do
          {
            city: 'Taipei',
            state: 'CA',
            address: 'abc',
            dist_code: '119',
            province_id: '1',
            country_code: 'TW',
            zip_code: '119'
          }
        end
        Given(:city) do
          double(DomainData::Taiwan::City, name: 'Taipei')
        end
        Given(:district) do
          double(DomainData::Taiwan::District, code: '119', name: 'Foo', city: city)
        end
        When do
          DomainData::Taiwan::District.stub(:[]).with('119').and_return(district)
          form.attributes = attributes
          form.save
          profile.reload
        end
        Given(:data) { profile.address_data }
        Then { expect(profile).to be_persisted }
        And { expect(profile.city).to eq 'Taipei' }
        And { expect(profile.state).to eq 'CA' }
        And { expect(profile.address).to eq 'abc' }
        And { expect(profile.country_code).to eq 'TW' }
        And { expect(profile.zip_code).to eq '119' }
        And { expect(data.city).to eq 'Taipei' }
        And { expect(data.state).to eq 'CA' }
        And { expect(data.address).to eq 'abc' }
        And { expect(data.country_code).to eq 'TW' }
        And { expect(data.zip_code).to eq '119' }
        And { expect(data.dist_code).to eq '119' }
        And { expect(data.dist).to eq 'Foo' }
      end
    end
  end
end
