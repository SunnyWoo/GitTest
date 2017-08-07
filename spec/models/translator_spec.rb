require 'spec_helper'

describe Translator do
  let(:translator){ Translator.new('foo.bar')}
  it 'creates correct translator object' do
    translator
    expect(translator).to be_valid
    expect(translator.key).to eq 'foo.bar'
  end

  it '#redis_value' do
    translator.value = "FooBar"
    expect(translator.value).to eq "FooBar"
    expect(translator.redis_value).to eq "\"FooBar\""
  end

  it '#set_redis_key' do
    translator.set_redis_key
    expect(translator.redis_key).to eq('en.foo.bar')
    translator.locale = "zh-TW"
    translator.set_redis_key
    expect(translator.redis_key).to eq('zh-TW.foo.bar')
  end

  it "#redis_value" do
    translator
    expect(translator.redis_value).to be_nil
    translator.value = "WTF"
    expect(translator.redis_value).to eq "\"WTF\""
  end

  it "#save_by_redis!" do
    redis = Redis::Namespace.new(:i18n, redis: $redis)
    translator
    expect{ translator.save_by_redis! }.to raise_error("Redis key and value must be provided!")
    translator.set_redis_key
    expect{ translator.save_by_redis! }.to raise_error("Redis key and value must be provided!")
    translator.value = "WTF"
    expect{ translator.save_by_redis! }.not_to raise_error
    expect(redis.get("en.foo.bar")).to eq("\"WTF\"")
    expect($redis.get("i18n:en.foo.bar")).to eq("\"WTF\"")
  end

  it '.[]' do
    Translator["snsd"].value = "Yoona"
    expect(Translator["snsd"].value).to eq "Yoona"
    expect(Translator["snsd"].key).to eq "snsd"
    expect(Translator["non.exist.key"]).to be_kind_of(Translator)
    expect(Translator["non.exist.key"].value).to eq nil
    expect{ Translator["non.exist.key", "non.exist.key2"] }.to raise_error(ArgumentError)
  end

  it ".key" do
    expect(Translator.key).to be_nil
    Translator.touch
    expect(Translator.key.to_i).to eq 1
    Translator.touch
    expect(Translator.key.to_i).to eq 2
  end

  it ".touch" do
    translator
    translator.value = "FooBarKing"
    expect(Translator.key).to be_nil
    translator.save_by_backend!
    expect(Translator.key.to_i).to eq 1
    translator.set_redis_key
    translator.save_by_redis!
    expect(Translator.key.to_i).to eq 1
  end

end
