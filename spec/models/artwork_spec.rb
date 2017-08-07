# == Schema Information
#
# Table name: artworks
#
#  id             :integer          not null, primary key
#  model_id       :integer
#  uuid           :string(255)
#  name           :string(255)
#  description    :text
#  work_type      :integer
#  finished       :boolean          default(FALSE)
#  featured       :boolean          default(FALSE)
#  position       :integer
#  created_at     :datetime
#  updated_at     :datetime
#  user_id        :integer
#  user_type      :string(255)
#  application_id :integer
#

require 'spec_helper'

RSpec.describe Artwork, type: :model do
  it 'FactoryGirl' do
    expect(create(:artwork)).to be_valid
  end

  it { is_expected.to be_kind_of(HasUniqueUUID) }

  it { should belong_to(:product) }
  it { should have_many(:works) }
  it { should validate_presence_of(:product) }
  it { is_expected.to have_many :wishlists }
end
