# == Schema Information
#
# Table name: work_specs
#
#  id                                        :integer          not null, primary key
#  model_id                                  :integer
#  name                                      :string(255)
#  description                               :text
#  width                                     :float
#  height                                    :float
#  dpi                                       :integer          default(300)
#  created_at                                :datetime
#  updated_at                                :datetime
#  background_image                          :string(255)
#  overlay_image                             :string(255)
#  shape                                     :string(255)
#  alignment_points                          :string(255)
#  padding_top                               :decimal(8, 2)    default(0.0), not null
#  padding_right                             :decimal(8, 2)    default(0.0), not null
#  padding_bottom                            :decimal(8, 2)    default(0.0), not null
#  padding_left                              :decimal(8, 2)    default(0.0), not null
#  background_color                          :string(255)      default("white"), not null
#  variant_id                                :integer
#  dir_name                                  :string
#  placeholder_image                         :string
#  enable_white                              :boolean          default(FALSE)
#  auto_imposite                             :boolean          default(FALSE)
#  watermark                                 :string
#  print_image_mask                          :string
#  enable_composite_with_horizontal_rotation :boolean          default(FALSE)
#  create_order_image_by_cover_image         :boolean          default(FALSE)
#  enable_back_image                         :boolean          default(FALSE)
#

require 'spec_helper'

RSpec.describe WorkSpec, type: :model do
  it { is_expected.to strip_attribute :name }

  it { should belong_to(:variant) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:width) }
  it { should validate_presence_of(:height) }
  it { should validate_presence_of(:dpi) }
  it { should allow_value('rectangle').for(:shape) }
  it { should allow_value('ellipse').for(:shape) }
  it { should_not allow_value('triangle').for(:shape) }

  describe '#width and #height' do
    context 'when not give unit' do
      it 'returns original value (mm)' do
        work_spec = create(:work_spec, width: 100, height: 200)
        expect(work_spec.width).to eq(work_spec.width)
        expect(work_spec.height).to eq(work_spec.height)
      end
    end

    context 'when gives unit px' do
      it 'returns px value' do
        work_spec = create(:work_spec, width: 100, height: 200)
        expect(work_spec.width(:px)).to eq(work_spec.width * 2.84)
        expect(work_spec.height(:px)).to eq(work_spec.height * 2.84)
      end
    end

    context 'when gives unit inch' do
      it 'returns inch value' do
        work_spec = create(:work_spec, width: 100, height: 200)
        expect(work_spec.width(:inch)).to eq(work_spec.width / 25.4)
        expect(work_spec.height(:inch)).to eq(work_spec.height / 25.4)
      end
    end
  end
end
