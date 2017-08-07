# == Schema Information
#
# Table name: archived_layers
#
#  id             :integer          not null, primary key
#  work_id        :integer
#  layer_type     :string(255)
#  orientation    :float            default(0.0)
#  scale_x        :float            default(1.0)
#  scale_y        :float            default(1.0)
#  color          :string(255)
#  transparent    :float            default(1.0)
#  font_name      :string(255)
#  font_text      :text
#  image          :string(255)
#  filter         :string(255)
#  filtered_image :string(255)
#  material_name  :string(255)
#  position_x     :float            default(0.0)
#  position_y     :float            default(0.0)
#  text_spacing_x :float            default(0.0)
#  text_spacing_y :float            default(0.0)
#  text_alignment :string(255)
#  position       :integer
#  image_meta     :json
#  created_at     :datetime
#  updated_at     :datetime
#  disabled       :boolean          default(FALSE), not null
#  mask_id        :integer
#

require 'rails_helper'

RSpec.describe ArchivedLayer do
  it { should have_attachment(:image) }
  it { should have_attachment(:filtered_image) }
end
