require 'spec_helper'

describe ApplicationPolicy do
  let(:user) { nil }
  let(:country_code) { 'TW' }
  let(:context) { AuthorizationWithContext::Context.new(user, country_code) }
  let(:model) { nil }
  subject(:policy) { ApplicationPolicy.new(context, model) }

  it 'has default behaviors' do
    expect(policy.index?).to be(false)
    expect(policy.create?).to be(false)
    expect(policy.new?).to be(false)
    expect(policy.update?).to be(false)
    expect(policy.edit?).to be(false)
    expect(policy.destroy?).to be(false)
  end
end
