# == Schema Information
#
# Table name: product_materials
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ProductMaterial < ActiveRecord::Base
  include UpcaseCode
  has_many :products, class_name: 'ProductModel', foreign_key: :material_id

  validates :code, uniqueness: true, presence: true, length: { is: 3 }

  def self.select_collections
    all.each_with_object({}) do |material, material_hash|
      material_hash["#{material.code} (#{material.description})"] = material.id
    end
  end
end
