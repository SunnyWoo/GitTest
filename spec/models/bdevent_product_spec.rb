# == Schema Information
#
# Table name: bdevent_products
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  product_id :integer
#  image      :string(255)
#  info       :json
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe BdeventProduct, type: :model do
  it { should belong_to(:product) }
  it { should belong_to(:bdevent) }
  it { should validate_uniqueness_of(:bdevent_id).scoped_to(:product_id) }
  it 'is for FactoryGirl' do
    expect(build(:bdevent_product)).to be_valid
  end
end
