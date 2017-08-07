# == Schema Information
#
# Table name: masks
#
#  id            :integer          not null, primary key
#  material_name :string(255)
#  image         :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  image_meta    :json
#

require 'rails_helper'

RSpec.describe Mask, type: :model do
  it 'FactoryGirl' do
    expect(create(:mask)).to be_valid
  end
end
