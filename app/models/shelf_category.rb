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

class ShelfCategory < ActiveRecord::Base
  acts_as_paranoid
  has_many :shelves, foreign_key: :material_id
  belongs_to :factory

  validates :name, uniqueness: { scope: :factory_id }
end
