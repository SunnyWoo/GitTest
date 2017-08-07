# == Schema Information
#
# Table name: product_option_types
#
#  id             :integer          not null, primary key
#  product_id     :integer
#  option_type_id :integer
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class ProductOptionType < ActiveRecord::Base
  acts_as_list scope: :product

  belongs_to :product, class_name: 'ProductModel'
  belongs_to :option_type

  validates :product, :option_type, presence: true
  validates :product_id, uniqueness: { scope: :option_type_id }
end
