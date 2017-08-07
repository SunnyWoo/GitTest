# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  avatar                 :string(255)
#  role                   :integer
#  profile                :hstore
#  gender                 :integer
#  background             :string(255)
#  image_meta             :json
#  mobile                 :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  mobile_country_code    :string(16)
#

require 'spec_helper'

describe User do
  it 'FactoryGirl' do
    expect(build(:user)).to be_valid
  end

  it { should have_many(:omniauths) }
  it { should have_many(:devices) }
  it { should have_many(:works) }
  it { should have_many(:layers) }
  it { should have_many(:orders) }
  it { should have_many(:address_infos) }
  it { is_expected.to have_one :wishlist }
  it { is_expected.to validate_uniqueness_of(:email).allow_blank }
  it { is_expected.to validate_uniqueness_of(:mobile).allow_blank }

  let(:user) { create(:user) }

  context '#guest_to_user_from_access_token' do
    it 'return true when access_token is valid' do
      guest = User.new_guest
      guest_token = create(:access_token, resource_owner_id: guest.id, scopes: 'public')
      expect(user.guest_to_user_from_access_token(guest_token.token)).to be_truthy
      expect(guest.tap(&:reload).role).to eq('die')
      expect(guest.migrate_to_user_id.to_i).to eq(user.id)
    end

    it 'return nil when access_token is invalid' do
      token = 'xxx'
      expect(user.guest_to_user_from_access_token(token)).to be_nil
    end
  end

  context '#send_password_reset_token' do
    it 'returns public reset_password_token' do
      expect(user.reset_password_token).to be_nil
      expect(user.reset_password_sent_at).to be_nil
      token = user.send_password_reset_token
      encrypt_token = Devise.token_generator.digest(User, :reset_password_token, token)
      expect(encrypt_token).to eq user.reset_password_token
      expect(user.reset_password_sent_at).not_to be_nil
    end

    it 'sends reset_password_token_mail' do
      expect { user.send_password_reset_token }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'creates an send_password_reset activity' do
      user.send_password_reset_token
      activity = user.activities.last
      expect(activity.key).to eq('send_password_reset')
      expect(activity.extra_info[:url]).to eq('default')
    end

    it 'creates an send_password_reset activity with url' do
      user.send_password_reset_token('http://commandp.dev/')
      activity = user.activities.last
      expect(activity.extra_info[:url]).to eq('http://commandp.dev/')
    end
  end

  context '#send_confirmation_email' do
    Given(:user) { create :user }

    context 'after send_confirmation_email' do
      Given!(:count) { ActionMailer::Base.deliveries.count }
      When { user.send_confirmation_token('http:commandp.dev') }
      Then { ActionMailer::Base.deliveries.count == count + 1 }
      And { user.activities.last.key == 'send_confirmation_token' }
      And { user.activities.last.extra_info[:url] == 'http:commandp.dev' }
    end
  end

  context '#send_coupon_for_the_fresh_china' do
    before do
      3.times do
        create(:coupon_notice, platform: { 'mobile' => true, 'email' => true })
      end
    end
    it 'does nothing if user did not come from china' do
      create :user
      assert_equal 0, MobileCouponSendWorker.jobs.size
    end

    it 'does nothing if user does come from china but as a guest' do
      stub_env('REGION', 'china')
      create :user, role: :guest
      assert_equal 0, MobileCouponSendWorker.jobs.size
    end

    it 'does nothing if the comes from china without mobile' do
      stub_env('REGION', 'china')
      create :user
      assert_equal 0, MobileCouponSendWorker.jobs.size
    end

    it 'invokes Mission MobileCouponSendWorker: Rogue Coupon if mobile provided' do
      stub_env('REGION', 'china')
      user_with_guest_email = create :user, email: User.random_email
      user_with_guest_email.update mobile: '0922333444'
      assert_equal CouponNotice.china.mobile_available.size, MobileCouponSendWorker.jobs.size
    end

    it 'invokes Mission EmailCouponSendWorker: Rogue Coupon if email provided' do
      stub_env('REGION', 'china')
      user = create :user, email: 'cmd@commandp.com'
      assert_equal 1, EmailCouponSendWorker.jobs.size
      user.update email: 'cmd2@commandp.com'
      assert_equal 1, EmailCouponSendWorker.jobs.size
    end

    it 'dose nothing if the user is got the fresh coupon already' do
      stub_env('REGION', 'china')
      user_with_guest_email = create :user, email: User.random_email
      user_with_guest_email.update mobile: '0922333444'
      assert_equal CouponNotice.china.mobile_available.size, MobileCouponSendWorker.jobs.size
      user_with_guest_email.update mobile: '0933444555'
      assert_equal CouponNotice.china.mobile_available.size, MobileCouponSendWorker.jobs.size
    end
  end

  it 'check user profile' do
    user = create(:user, first_name: 'First Name', last_name: 'Last Name',
                         mobile_country_code: 'TW', birthday: '1990-01-01')
    expect(user.first_name).to eq('First Name')
    expect(user.last_name).to eq('Last Name')
    expect(user.mobile_country_code).to eq('TW')
    expect(user.birthday).to eq('1990-01-01')
  end

  context 'do not confirm the user' do
    context 'when from_omniauth' do
      Given(:auth) do
        set_twitter_omniauth
        OmniAuth.config.mock_auth[:twitter]
      end
      Given!(:user_count) { User.count }
      When { User.from_omniauth(auth, nil) }
      Then { User.count == user_count + 1 }
      And { User.last.confirmed? }
      And { User.last.omniauths.last.provider == 'twitter' }
    end

    context 'when new_guest' do
      When { User.new_guest }
      Then { User.last.confirmed? }
      And { User.last.guest? }
    end
  end

  context '#enqueue_post_to_mailgun_mailing_list' do
    it 'when user is Guest' do
      user = User.new_guest
      expect(user.enqueue_post_to_mailgun_mailing_list).to be_nil
    end

    it 'when user is Normal' do
      create(:user)
      expect(MailgunAddMailingListWorker.jobs.size).to be(2)
      expect(MailgunDeleteMailingListWorker.jobs.size).to be(1)
    end

    it 'when user is Normal and email is guest_xxx@commandp.com' do
      user = create(:user, email: 'guest_xxx@commandp.com')
      expect(user.enqueue_post_to_mailgun_mailing_list).to be_nil
    end
  end

  context '#have_many work' do
    Given(:designer) { create(:designer, id: '99999') }
    Given(:user) { create(:user, id: '99999') }
    Given {
      create(:work, user: designer)
      create(:work, user: user)
    }
    Then { user.id == designer.id }
    And { user.works.count == 1 }
    And { designer.works.count == 1 }
  end

  context '#code' do
    Given(:user) { create :user }
    Then { user.code == '0000' }
  end

  context '#access_token' do
    Given { create(:application, name: 'api') }
    Then { Doorkeeper::AccessToken.find_by(resource_owner_id: user.id).try(:token).nil? }
    And { user.access_token.present? }
    And {
      Doorkeeper::AccessToken.find_by(resource_owner_id: user.id, scopes: 'public').try(:token) == user.access_token
    }
    And { Doorkeeper::AccessToken.find_by(resource_owner_id: user.id).try(:scopes).to_s == 'public' }
  end
end
