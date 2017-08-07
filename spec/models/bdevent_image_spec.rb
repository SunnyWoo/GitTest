# == Schema Information
#
# Table name: bdevent_images
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  locale     :string(255)
#  file       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe BdeventImage, type: :model do
  it 'FactoryGirl' do
    expect(create(:bdevent_image)).to be_valid
  end
end
