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

require 'rails_helper'

RSpec.describe AssetPackageCollecting, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
