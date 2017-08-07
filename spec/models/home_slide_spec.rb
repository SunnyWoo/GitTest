# == Schema Information
#
# Table name: home_slides
#
#  id         :integer          not null, primary key
#  slide      :string(255)
#  is_enabled :boolean          default(TRUE)
#  created_at :datetime
#  updated_at :datetime
#  title      :text
#  link       :string(255)
#  template   :integer          default(0)
#  desc       :hstore
#  background :string(255)
#  priority   :integer          default(1)
#  set        :string(255)
#

require 'spec_helper'

describe HomeSlide do
  it 'FactoryGirl' do
    expect(build(:home_slide)).to be_valid
  end
end
