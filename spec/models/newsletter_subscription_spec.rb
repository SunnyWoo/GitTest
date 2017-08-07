# == Schema Information
#
# Table name: newsletter_subscriptions
#
#  id           :integer          not null, primary key
#  email        :string(255)
#  locale       :string(255)
#  is_enabled   :boolean          default(TRUE)
#  created_at   :datetime
#  updated_at   :datetime
#  country_code :string(255)
#

require 'rails_helper'

RSpec.describe NewsletterSubscription, type: :model do
  it 'FactoryGirl' do
    expect( build(:newsletter_subscription) ).to be_valid
  end

  it { should validate_uniqueness_of(:email) }

  context 'validate email' do
    it '#return false' do
      expect(build(:newsletter_subscription, email: 'mail')).to be_invalid
    end

    it '#return true' do
      expect(build(:newsletter_subscription, email: 'abc@mail.com')).to be_valid
    end
  end

  context 'downcase email' do
    before do
      @newsletter_subscription = create(:newsletter_subscription,
                                        email: 'DOWNCASE@EMAIL.COM')
    end

    it '#return false' do
      expect(@newsletter_subscription.email).not_to eq('DOWNCASE@EMAIL.COM')
    end

    it '#return true' do
      expect(@newsletter_subscription.email).to eq('downcase@email.com')
    end
  end

end
