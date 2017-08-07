# == Schema Information
#
# Table name: assets
#
#  id          :integer          not null, primary key
#  package_id  :integer
#  available   :boolean          default(FALSE), not null
#  uuid        :string(255)
#  type        :string(255)
#  raster      :string(255)
#  vector      :string(255)
#  image_meta  :json
#  position    :integer
#  created_at  :datetime
#  updated_at  :datetime
#  colorizable :boolean          default(FALSE), not null
#

require 'rails_helper'

RSpec.describe Asset, :type => :model do
  it { is_expected.to be_kind_of(HasUniqueUUID) }
  it { should allow_value('sticker').for(:type) }
  it { should allow_value('coating').for(:type) }
  it { should allow_value('foiling').for(:type) }
  it { should_not allow_value('whatever').for(:type) }
end
