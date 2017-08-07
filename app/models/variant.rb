# == Schema Information
#
# Table name: variants
#
#  id         :integer          not null, primary key
#  product_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Variant < ActiveRecord::Base
  belongs_to :product, class_name: 'ProductModel'
  has_one :work_spec
  has_many :option_value_variants
  has_many :option_values, through: :option_value_variants

  accepts_nested_attributes_for :work_spec

  def options_text
    option_values.map(&:presentation_with_option_type).join(', ')
  end
end
