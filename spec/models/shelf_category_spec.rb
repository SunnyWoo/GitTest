# == Schema Information
#
# Table name: shelf_categories
#
#  id          :integer          not null, primary key
#  factory_id  :integer
#  name        :string(255)      not null
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  deleted_at  :datetime
#

require 'rails_helper'

RSpec.describe ShelfCategory, type: :model do
  it_behaves_like 'soft_delete'

  it { is_expected.to belong_to(:factory) }
  it { is_expected.to have_many(:shelves) }
  it { is_expected.to validate_uniqueness_of(:name).scoped_to(:factory_id) }

  it 'FactoryGirl' do
    expect(create(:shelf_material)).to be_valid
  end
end
