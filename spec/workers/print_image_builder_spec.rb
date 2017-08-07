require 'spec_helper'

describe PrintImageBuilder do
  describe '#perform' do
    it 'builds print image' do
      work = create(:work)
      expect(GlobalID::Locator).to receive(:locate).with(work.to_gid).and_return(work)
      expect(work).to receive(:build_print_image)
      PrintImageBuilder.new.perform(work.to_gid)
    end

    it 'creates begin and end activities' do
      work = create(:work)
      expect(GlobalID::Locator).to receive(:locate).with(work.to_gid).and_return(work)
      expect(work).to receive(:build_print_image)
      PrintImageBuilder.new.perform(work.to_gid)

      activities = work.activities.last(2)
      expect(activities.map(&:key)).to eq(%w(begin_build_print_image
                                             end_build_print_image))
    end
  end
end
