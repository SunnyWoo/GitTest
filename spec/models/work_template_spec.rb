# == Schema Information
#
# Table name: work_templates
#
#  id               :integer          not null, primary key
#  model_id         :integer
#  background_image :string(255)
#  overlay_image    :string(255)
#  aasm_state       :string(255)
#  masks            :json
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

RSpec.describe WorkTemplate, type: :model do
  it 'FactoryGirl' do
    expect(create(:work_template)).to be_valid
  end

  it { should belong_to(:product) }

  describe '#masks' do
    it 'stores an array of masks correctly' do
      create(:work_template, masks: [WorkTemplateMask.new({}),
                                     WorkTemplateMask.new({})])
      expect(WorkTemplate.last.masks.count).to eq(2)
      expect(WorkTemplate.last.masks[0]).to be_a(WorkTemplateMask)
      expect(WorkTemplate.last.masks[1]).to be_a(WorkTemplateMask)
    end
  end
end
