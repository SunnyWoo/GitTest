require 'spec_helper'

Temping.create :dummy_class do
  with_columns do |t|
    t.string :uuid
  end
  include HasUniqueUUID
end

describe HasUniqueUUID do
  context 'validates' do
    Given(:dummy) { DummyClass.create }
    Then { expect(dummy).to have_readonly_attribute(:uuid) }
    And { expect(dummy).to allow_value(SecureRandom.uuid).for(:uuid) }
    And { expect(dummy).to allow_value(nil).for(:uuid) }
    And { expect(dummy).to validate_uniqueness_of(:uuid) }
    And { expect(dummy).to respond_to(:generate_uuid) }
  end

  context 'callback generate_uuid if uuid is nil' do
    Given(:dummy) { DummyClass.create uuid: nil }
    Then { !dummy.uuid.nil? }
  end

  context 'skip callback if uuid' do
    Given(:dummy) { DummyClass.create uuid: 'ac1113d8-8855-11e5-86bd-a0999b1a359b' }
    Then { dummy.uuid == 'ac1113d8-8855-11e5-86bd-a0999b1a359b' }
  end
end
