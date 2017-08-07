# == Schema Information
#
# Table name: picking_materials
#
#  id         :integer          not null, primary key
#  model_id   :integer
#  material   :string(255)
#  quantity   :integer          default(1), not null
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe PickingMaterial, type: :model do
  it { is_expected.to belong_to(:product) }
end
