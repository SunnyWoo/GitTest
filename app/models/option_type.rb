# == Schema Information
#
# Table name: option_types
#
#  id           :integer          not null, primary key
#  name         :string
#  presentation :string
#  position     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class OptionType < ActiveRecord::Base
  has_many :products, through: :product_option_types
  with_options dependent: :destroy do
    has_many :option_values
    has_many :product_option_types
  end

  with_options presence: true do
    validates :name, uniqueness: true
    validates :presentation
  end

  accepts_nested_attributes_for :option_values,
                                reject_if: lambda { |ov| ov[:name].blank? || ov[:presentation].blank? },
                                allow_destroy: true
end
