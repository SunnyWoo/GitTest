# == Schema Information
#
# Table name: asset_packages
#
#  id              :integer          not null, primary key
#  designer_id     :integer
#  icon            :string(255)
#  available       :boolean          default(FALSE), not null
#  begin_at        :date
#  end_at          :date
#  countries       :string(255)      default([]), is an Array
#  position        :integer
#  image_meta      :json
#  created_at      :datetime
#  updated_at      :datetime
#  category_id     :integer
#  downloads_count :integer          default(0)
#

require 'rails_helper'

describe AssetPackage, type: :model do
  it { should belong_to(:category) }

  it '#count_download' do
    package = create :available_asset_package
    expect(package.downloads_count).to eq 0
    expect(package.category.downloads_count).to eq 0
    package.count_download
    expect(package.reload.downloads_count).to eq 1
    expect(package.category.downloads_count).to eq 1
  end
end
