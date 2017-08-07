# == Schema Information
#
# Table name: product_specs
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ProductSpec < ActiveRecord::Base
  include UpcaseCode

  has_many :products, class_name: 'ProductModel', foreign_key: :spec_id

  validates :code, uniqueness: true, presence: true, length: { is: 1 }

  def self.select_collections
    all.each_with_object({}) do |spec, spec_hash|
      spec_hash["#{spec.code} (#{spec.description})"] = spec.id
    end
  end
end
