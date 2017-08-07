# == Schema Information
#
# Table name: billing_profiles
#
#  id            :integer          not null, primary key
#  address       :text
#  city          :string(255)
#  name          :string(255)
#  phone         :string(255)
#  state         :string(255)
#  zip_code      :string(255)
#  country       :string(255)
#  billable_id   :integer
#  billable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  country_code  :string(255)
#  shipping_way  :integer          default(0)
#  email         :string(255)
#  type          :string(255)
#  address_name  :string(255)
#  memo          :hstore
#  province_id   :integer
#  address_data  :json
#

require 'spec_helper'

describe BillingProfile do
  it 'FactoryGirl' do
    expect(build(:billing_profile)).to be_valid
  end

  %i(city name phone state zip_code email address_name).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  it { is_expected.to validate_presence_of :country_code }
  it { is_expected.to validate_inclusion_of(:country_code).in_array(BillingProfile::COUNTRY_CODES) }
  it { is_expected.to validate_presence_of :address }
  it { is_expected.to validate_presence_of :phone }

  context 'set country code' do
    it 'return country' do
      BillingProfile.countries_with_country_code.each do |country, code|
        billing = BillingProfile.create(country_code: code, email: Faker::Internet.free_email)
        expect(billing.country).to eq(country)
      end
    end
  end

  context 'check_input_english' do
    it 'address is not english' do
      billing = BillingProfile.create(address: '中文', country_code: 'AU', email: Faker::Internet.free_email,
                                      phone: '0228825252')
      expect(billing.valid?).to eq(false)
    end

    it 'name is not english' do
      billing = BillingProfile.create(name: '中文', country_code: 'AU', email: Faker::Internet.free_email,
                                      address: 'Jedi Planet', phone: '0228825252')
      expect(billing.valid?).to eq(false)
    end

    it 'city is not english' do
      billing = BillingProfile.create(city: '中文', country_code: 'AU', email: Faker::Internet.free_email,
                                      address: 'Jedi Planet', phone: '0228825252')
      expect(billing.valid?).to eq(false)
    end

    %w(HK MO CN JP TW).each do |code|
      it "city is not english when country_code is #{code}" do
        billing = BillingProfile.create(address: '中文', name: '中文', city: '中文', country_code: code,
                                        email: Faker::Internet.free_email, phone: '0228825252')
        expect(billing.valid?).to eq(true)
      end
    end

    it 'city address name is english' do
      billing = BillingProfile.create(address: 'valid', name: 'valid', city: 'vaid', country_code: 'AU',
                                      email: Faker::Internet.free_email, phone: '0228825252')
      expect(billing.valid?).to eq(true)
    end
  end

  context 'full address' do
    context 'country_code is CN' do
      Given(:billing_profile) { build(:billing_profile, country_code: 'CN') }
      Given(:address) do
        "#{billing_profile.country} #{billing_profile.state} #{billing_profile.city} #{billing_profile.address}"
      end
      Then { billing_profile.full_address == address }
    end

    context 'country_code is not CN' do
      Given(:billing_profile) { build(:billing_profile, country_code: 'TW') }
      Given(:address) { "#{billing_profile.country} #{billing_profile.city} #{billing_profile.address}" }
      Then { billing_profile.full_address == address }
    end
  end

  describe '#convert_legacy_address' do
    Given { ImportShippingFeeService.import_china_shipping_fee }

    context 'stored province in city' do
      Given(:billing_profile) do
        build(
          :billing_profile,
          country_code: 'CN',
          address: '徐汇区 凯旋路3500号华苑大厦1座31号楼b',
          city: '上海', state: '', country: 'China'
        )
      end
      When(:address) { billing_profile.convert_legacy_address }
      Then { expect(address).to be_kind_of(Address) }
      And { expect(address.province_id).to eq Province.find_by_name('上海市').id }
    end

    context 'stored province in state' do
      Given(:billing_profile) do
        build(
          :billing_profile,
          country_code: 'CN',
          address: '宿城区亚方花园6栋303',
          city: '宿迁市', state: '江苏省', country: 'China'
        )
      end
      When(:address) { billing_profile.convert_legacy_address }
      Then { expect(address).to be_kind_of(Address) }
      And { expect(address.province_id).to eq Province.find_by_name('江苏省').id }
    end
  end
end
