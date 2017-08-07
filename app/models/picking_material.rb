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

class PickingMaterial < ActiveRecord::Base
  belongs_to :product, class_name: 'ProductModel', foreign_key: :model_id

  validates :material, presence: true
end
