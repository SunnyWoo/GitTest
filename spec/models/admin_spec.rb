# == Schema Information
#
# Table name: admins
#
#  id                     :integer          not null, primary key
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
#  created_at             :datetime
#  updated_at             :datetime
#  failed_attempts        :integer          default(0), not null
#  locked_at              :datetime
#

require 'spec_helper'

describe Admin do
  it 'FactoryGirl' do
    expect(build(:admin)).to be_valid
  end

  it { should_not allow_value('12341234').for(:password) }
  it { should_not allow_value('a1234567').for(:password) }
  it { should allow_value('AkG12345').for(:password) }
end
