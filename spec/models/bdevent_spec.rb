# == Schema Information
#
# Table name: bdevents
#
#  id         :integer          not null, primary key
#  uuid       :string(255)
#  starts_at  :datetime
#  ends_at    :datetime
#  priority   :integer          default(1)
#  is_enabled :boolean
#  event_type :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#  background :string(255)
#

require 'rails_helper'

RSpec.describe Bdevent, type: :model do
  it 'FactoryGirl' do
    expect(create(:bdevent)).to be_valid
  end

  it { should have_one(:bdevent_redeem) }
  it { should have_many(:works) }
  it { should have_many(:products) }

  context '#kv_images' do
    before do
      @bdevent = create(:bdevent)
      create(:bdevent_image, bdevent: @bdevent, locale: :en)
    end

    it 'when locale is en' do
      I18n.locale = :en
      expect(@bdevent.kv_images.size).to eq(1)
    end

    it 'when locele is zh-TW' do
      I18n.locale = 'zh-TW'
      expect(@bdevent.kv_images.size).to eq(0)
      expect(@bdevent.bdevent_images.count).to eq(1)
      create(:bdevent_image, bdevent: @bdevent, locale: 'zh-TW')
      expect(@bdevent.tap(&:reload).kv_images.size).to eq(1)
      expect(@bdevent.bdevent_images.count).to eq(2)
    end
  end

  context '#event_available' do
    it 'return available event' do
      create(:bdevent)
      expect(Bdevent.event_available.size).to eq(1)
    end

    it 'return nil' do
      create(:bdevent, ends_at: Time.zone.now - 1.hour)
      expect(Bdevent.event_available.size).to eq(0)
    end
  end

  context '#coming_available' do
    it 'return available event' do
      create(:bdevent, event_type: :coming)
      expect(Bdevent.coming_available.size).to eq(1)
    end

    it 'return nil' do
      create(:bdevent, event_type: :coming, ends_at: Time.zone.now - 1.hour)
      expect(Bdevent.coming_available.size).to eq(0)
    end
  end

  context 'translations get default locale(zh-TW) value ' do
    before do
      @bdevent = create(:bdevent)
      tmp = @bdevent.translations.find_by(locale: 'zh-TW')
      tmp.update title: 'zh-TW title', desc: 'zh-TW desc'
      @bdevent.tap(&:reload)
    end

    it 'when locale is en' do
      I18n.locale = 'en'
      expect(@bdevent.title).to eq(@bdevent.translation_for('zh-TW').title)
      expect(@bdevent.desc).to eq(@bdevent.translation_for('zh-TW').desc)
      expect(@bdevent.banner).to eq(@bdevent.translation_for('zh-TW').banner)
      expect(@bdevent.coming_soon_image).to eq(@bdevent.translation_for('zh-TW').coming_soon_image)

      expect(@bdevent.translation_for('en').title).to be_nil
      expect(@bdevent.translation_for('en').desc).to be_nil
      expect(@bdevent.translation_for('en').banner.url).to be_nil
      expect(@bdevent.translation_for('en').coming_soon_image.url).to be_nil
    end

    it 'when locale is zh-TW' do
      I18n.locale = 'zh-TW'
      expect(@bdevent.title).to eq(@bdevent.translation_for('zh-TW').title)
      expect(@bdevent.desc).to eq(@bdevent.translation_for('zh-TW').desc)
      expect(@bdevent.banner).to eq(@bdevent.translation_for('zh-TW').banner)
      expect(@bdevent.coming_soon_image).to eq(@bdevent.translation_for('zh-TW').coming_soon_image)
    end
  end

  context '#bdevent_works' do
    before do
      @bdevent = create(:bdevent)
      @bdevent_work = create(:bdevent_work, bdevent: @bdevent, position: 2)
      @bdevent_work_2 = create(:bdevent_work, bdevent: @bdevent, position: 3)
      @bdevent_work_3 = create(:bdevent_work, bdevent: @bdevent, position: 1)
    end

    it 'check bdevent_works sort' do
      @bdevent.tap(&:reload)
      expect(@bdevent.bdevent_works.first.id).to eq(@bdevent_work_2.id)
      expect(@bdevent.bdevent_works.last.id).to eq(@bdevent_work_3.id)
    end
  end
end
