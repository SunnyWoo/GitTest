# == Schema Information
#
# Table name: provinces
#
#  id         :integer          not null, primary key
#  area_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#  code       :string(2)
#

require 'rails_helper'

RSpec.describe Province, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
