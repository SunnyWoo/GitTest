# == Schema Information
#
# Table name: asset_package_collectings
#
#  id               :integer          not null, primary key
#  user_id          :integer
#  asset_package_id :integer
#  created_at       :datetime
#  updated_at       :datetime
#

class AssetPackageCollecting < ActiveRecord::Base
  belongs_to :user
  belongs_to :asset_package
end
