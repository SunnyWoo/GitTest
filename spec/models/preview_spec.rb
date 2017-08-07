# == Schema Information
#
# Table name: previews
#
#  id           :integer          not null, primary key
#  work_id      :integer
#  key          :string(255)
#  image        :string(255)
#  image_meta   :text
#  high_quality :boolean          default(FALSE), not null
#  created_at   :datetime
#  updated_at   :datetime
#  position     :integer
#  work_type    :string(255)
#

require 'spec_helper'

describe Preview, type: :model do
  it 'FactoryGirl' do
    expect(build(:preview)).to be_valid
  end

  it { should validate_uniqueness_of(:key).scoped_to([:work_id, :work_type]) }

  context 'prevent from generating the duplicated preview of a work' do
    Given(:preview) { create :preview }
    Given!(:work) { preview.work }
    Given!(:preview_count) { Preview.count }
    When { expect { create :preview, key: preview.key, work: work }.to raise_error(ActiveRecord::RecordInvalid) }
    Then { Preview.count == preview_count }
  end
end
