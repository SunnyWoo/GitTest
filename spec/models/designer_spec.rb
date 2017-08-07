# == Schema Information
#
# Table name: designers
#
#  id                     :integer          not null, primary key
#  username               :string(255)      default(""), not null
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  display_name           :string(255)
#  avatar                 :string(255)
#  description            :text
#  image_meta             :json
#  created_at             :datetime
#  updated_at             :datetime
#  code                   :string(255)
#

require 'rails_helper'

RSpec.describe Designer, type: :model do
  it { should validate_uniqueness_of(:username) }
  it { should validate_uniqueness_of(:email) }
  it { should validate_uniqueness_of(:code) }

  it 'can build by FactoryGirl' do
    expect(create(:designer)).to be_valid
  end

  it 'can use pg json and hashie/mash to store carrierwave metadata' do
    create(:designer, :with_avatar)
    designer = Designer.last
    expect(designer.image_meta).to be_a(Hashie::Mash)
    expect(designer.avatar.width).to eq(1)
    expect(designer.avatar.height).to eq(1)
  end

  context '#guest is false' do
    Given!(:designer) { create :designer }
    Then { designer.guest? == false }
  end

  context '#generate_code' do
    context 'when code blank' do
      Given!(:designer) { create :designer, code: nil }
      Then { designer.code.present? }
    end

    context 'when code present' do
      Given!(:designer) { create :designer, code: 1234 }
      Then { designer.code == '1234' }
    end
  end
end
