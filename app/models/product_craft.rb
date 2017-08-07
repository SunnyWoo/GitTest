# == Schema Information
#
# Table name: product_crafts
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ProductCraft < ActiveRecord::Base
  include UpcaseCode

  has_many :products, class_name: 'ProductModel', foreign_key: :craft_id

  validates :code, uniqueness: true, presence: true, length: { is: 1 }

  def self.select_collections
    all.each_with_object({}) do |craft, craft_hash|
      craft_hash["#{craft.code} (#{craft.description})"] = craft.id
    end
  end
end
