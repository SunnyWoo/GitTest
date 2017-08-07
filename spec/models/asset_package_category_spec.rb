# == Schema Information
#
# Table name: asset_package_categories
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  available       :boolean          default(FALSE), not null
#  created_at      :datetime
#  updated_at      :datetime
#  packages_count  :integer          default(0)
#  downloads_count :integer          default(0)
#

require 'spec_helper'

RSpec.describe AssetPackageCategory, type: :model do
  it 'FactoryGirl' do
    expect(build(:asset_package_category)).to be_valid
  end

  it { should have_many(:packages) }
end
