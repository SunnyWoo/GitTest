# == Schema Information
#
# Table name: bdevent_works
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  work_id    :integer
#  work_type  :string(255)
#  info       :json
#  image      :string(255)
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe BdeventWork, type: :model do
  it 'FactoryGirl' do
    expect(build(:bdevent_work)).to be_valid
  end
  it { should validate_uniqueness_of(:bdevent_id).scoped_to(:work_id) }
  it { should belong_to(:work) }
  it { should belong_to(:bdevent) }
end
