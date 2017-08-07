# == Schema Information
#
# Table name: notes
#
#  id            :integer          not null, primary key
#  message       :text
#  user_id       :integer
#  noteable_id   :integer
#  noteable_type :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  user_type     :string(255)
#

require 'rails_helper'

RSpec.describe Note, type: :model do
  # relations
  it { is_expected.to belong_to(:noteable) }
  it { is_expected.to belong_to(:user) }

  context 'default_scope' do
    Then { Note.all.to_sql == Note.reorder('').order(:created_at).to_sql }
  end

  it { is_expected.to delegate_method(:email).to(:user).with_prefix(:user) }

  context '#user_name' do
    Given(:note) { Note.new(user: user, noteable: nil) }
    context 'with user' do
      Given(:user) { build(:user, id: 10, email: 'usertest@commandp.me') }
      Then { note.user_name == 'usertest' }
    end

    context 'without user' do
      Given(:user) { nil }
      Then { note.user_name.nil? }
    end
  end
end
