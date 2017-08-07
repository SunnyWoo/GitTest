require 'spec_helper'

describe FactoryMemberSignIn do
  context '#save!' do
    Given(:factory) { create :factory, code: 'commandp' }
    Given!(:factory_member) { create :factory_member, username: 'commandp', factory: factory }

    context 'found user' do
      Given!(:form) { FactoryMemberSignIn.new(code: 'commandp', username: 'commandp', password: '12341234') }
      Then { form.save! == factory_member }
    end

    context 'code invalid' do
      Given!(:form) { FactoryMemberSignIn.new(code: 'invalid', username: 'commandp', password: '12341234') }
      Then { expect { form.save! }.to raise_error ActiveRecord::RecordInvalid }
    end

    context 'username invalid' do
      Given!(:form) { FactoryMemberSignIn.new(code: 'commandp', username: 'invalid', password: '12341234') }
      Then { expect { form.save! }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'password invalid' do
      Given!(:form) { FactoryMemberSignIn.new(code: 'commandp', username: 'commandp', password: 'invalid') }
      Then { expect { form.save! }.to raise_error ActiveRecord::RecordInvalid }
    end
  end
end
