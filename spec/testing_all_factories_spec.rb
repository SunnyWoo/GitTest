require 'spec_helper'

FactoryGirl.factories.map(&:name).each do |factory_name|
  describe "factory #{factory_name}" do
    before do
      CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
      CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
    end

    it 'is valid' do
      factory = create(factory_name)
      if factory.respond_to?(:valid?)
        expect(factory).to be_valid
      end
    end
  end

  describe 'with trait' do
    FactoryGirl.factories[factory_name].definition.defined_traits.map(&:name).each do |trait_name|
      it "is valid with trait #{trait_name}" do
        factory = create(factory_name, trait_name)
        if factory.respond_to?(:valid?)
          expect(factory).to be_valid
          # factory.should be_valid, lambda { factory.errors.full_messages.join(',') }
        end
      end
    end
  end
end
