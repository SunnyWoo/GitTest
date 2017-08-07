# == Schema Information
#
# Table name: preview_composers
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  model_id    :integer
#  layers      :text
#  created_at  :datetime
#  updated_at  :datetime
#  key         :string(255)
#  available   :boolean          default(FALSE), not null
#  position    :integer
#  template_id :integer
#

require 'rails_helper'

RSpec.describe PreviewComposer, type: :model do
  it { should validate_uniqueness_of(:key).scoped_to([:model_id, :template_id]) }
  it { should belong_to(:template) }

  describe 'after save' do
    it 'destroys all samples and enqueues preview samples builder', :freeze_time do
      composer = create(:preview_composer)
      composer.samples.create
      expect(composer.samples).not_to be_empty
      expect(PreviewSamplesBuilder).to receive(:perform_async).with(composer.id, composer.updated_at.to_s)
      composer.save
      expect(composer.samples).to be_empty
    end
  end
end
