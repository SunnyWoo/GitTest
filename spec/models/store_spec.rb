# == Schema Information
#
# Table name: stores
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  name                   :string(255)
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
#  title                  :string(255)
#  description            :text
#  avatar                 :string(255)
#  code                   :string(255)
#  slug                   :string(255)
#  tap_settings           :json
#  logo                   :string
#  store_footer_img       :string
#  contact_info           :hstore
#

require 'spec_helper'

describe Store, type: :model do
  it { should_not allow_value('12341234').for(:password) }
  it { should_not allow_value('a1234567').for(:password) }
  it { should allow_value('AkG12345').for(:password) }
  it { should have_many(:templates) }
  it { should have_many(:components) }
  it { should validate_uniqueness_of(:slug) }

  it 'FactoryGirl' do
    expect(build(:store)).to be_valid
  end

  Given(:store) { create(:store) }

  context '#logo' do
    context 'returns raise error' do
      # image 1x1
      Given(:image) { fixture_file_upload('test.jpg', 'image/jpeg') }
      Then {
        store.update(logo: image)
        expect(store).not_to be_valid
      }

      # image 450x600
      Given(:image) { fixture_file_upload('prev_test.jpg', 'image/jpeg') }
      Then {
        store.update(logo: image)
        expect(store).not_to be_valid
      }
    end

    context 'returns valid' do
      # image 100x100
      Given(:image) { fixture_file_upload('great-design.jpg', 'image/jpeg') }
      Then {
        store.update(logo: image)
        expect(store).to be_valid
      }
    end
  end

  context '#enqueue_generate_store_footer_img' do
    context 'when logo changed' do
      Given(:image) { fixture_file_upload('great-design.jpg', 'image/jpeg') }
      When { store.update(logo: image) }
      Then { assert_equal 1, GenerateStoreFooterImgWorker.jobs.size }
    end

    context 'when slug changed' do
      Given(:store) { create(:store, logo: fixture_file_upload('great-design.jpg', 'image/jpeg')) }
      When { store.update(slug: 'slug_test') }
      Then { assert_equal 2, GenerateStoreFooterImgWorker.jobs.size }
    end
  end

  context '#url' do
    before do
      allow(Settings).to receive(:host) { host }
    end

    context 'Region is global' do
      Given(:host) { 'https://commandp.com' }
      Then { store.url == "https://store.commandp.com/en/#{store.slug}" }
    end

    context 'Region is china' do
      Given { stub_env('REGION', 'china') }
      Given(:host) { 'https://commandp.com.cn' }
      Then { store.url == "https://store.commandp.com.cn/en/#{store.slug}" }
    end
  end
end
