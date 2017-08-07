# == Schema Information
#
# Table name: factories
#
#  id            :integer          not null, primary key
#  code          :string(255)
#  name          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  contact_email :text
#  locale        :string(255)
#

require 'spec_helper'

RSpec.describe Factory, type: :model do
  %i(code name).each do |attr|
    it { is_expected.to strip_attribute attr }
  end

  context '#dropbox' do
    it 'returns nil if dropbox did not logged in' do
      expect(create(:factory).dropbox).to be_nil
    end

    it 'returns dropbox omniauth if dropbox logged in' do
      factory = create(:factory_with_dropbox)
      expect(factory.dropbox).to be_a(Omniauth)
      expect(factory.dropbox.provider).to eq('dropbox')
    end
  end

  let!(:access_token) { OpenStruct.new(token: SecureRandom.hex, secret: SecureRandom.hex) }

  it '#save_omniauth' do
    factory = create(:factory)
    expect(factory.omniauths.count).to eq 0
    factory.send(:save_omniauth, access_token, 12_345)
    expect(factory.omniauths.count).to eq 1
    expect(factory.omniauths.first.uid).to eq 12_345.to_s
  end

  context 'valid locale' do
    Factory::LOCALES.each do |locale|
      it{ expect(build(:factory, locale: locale)).to be_valid }
    end
    it{ expect(build(:factory, locale: nil)).not_to be_valid }
    it{ expect(build(:factory, locale: 'gg')).not_to be_valid }
  end
end
