require 'spec_helper'

describe I18nBackendService do
  context '.save_from_yml_to_redis' do
    it 'when correct' do
      redis = Redis::Namespace.new(:i18n, redis: $redis)
      expect(redis.keys.length).to eq 0
      #tmp/test_i18n.yml
      I18nBackendService.save_from_yml_to_redis("spec/support/test_locales/")
      expect(redis.keys.length).not_to eq 0
      expect(redis.get "en.test.name").to eq "\"Test King!\""
    end

    it 'when not suppored type' do
      redis = Redis::Namespace.new(:i18n, redis: $redis)
      expect(redis.keys.length).to eq 0
      I18nBackendService.save_from_yml_to_redis("spec/support/test_locales/")
      expect(redis.keys.length).not_to eq 0
      expect(redis.get "en.date.message").to be_nil
      expect(redis.get "en.datetime.message").to be_nil
      expect(redis.get "en.time.message").to be_nil
      expect(redis.get "en.number.message").to be_nil
    end
  end

  context '.savefrom_redis_to_db' do

    it 'when redis provides correct data' do
      redis = Redis::Namespace.new(:i18n, redis: $redis)
      key = "en.test.foo.bar"
      redis.set key, "\'Test King!\'"
      I18nBackendService.save_from_redis_to_db
      expect(Translation.count).to eq 1
      i18n_from_db = Translation.first
      expect(i18n_from_db.locale).to eq "en"
      expect(i18n_from_db.key).to eq "test.foo.bar"
      expect(i18n_from_db.value).to eq "Test King!"
      redis.set key, "Test King!"
      I18nBackendService.save_from_redis_to_db
      expect(Translation.count).to eq 1
      expect(Translation.last.value).to eq "Test King!"
    end

    it 'when redis provides no data' do
      count = Translation.count
      I18nBackendService.save_from_redis_to_db
      new_count = Translation.count
      expect(new_count).to eq(count)
    end

    context 'when redis provides wrong data' do

      it "no locale" do
        redis = Redis::Namespace.new(:i18n, redis: $redis)
        key = "test.foo.bar"
        redis.set key, "\'Test King!\'"
        expect(redis.keys.length).to eq 1
        I18nBackendService.save_from_redis_to_db
        expect(Translation.count).to eq 0
      end

      it "wrong locale" do
        redis = Redis::Namespace.new(:i18n, redis: $redis)
        key = "fuck.foo.bar"
        redis.set key, "\'Test King!\'"
        expect(redis.keys.length).to eq 1
        I18nBackendService.save_from_redis_to_db
        expect(Translation.count).to eq 0
      end
    end

  end

end
