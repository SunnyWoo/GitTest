# == Schema Information
#
# Table name: option_values
#
#  id             :integer          not null, primary key
#  option_type_id :integer
#  name           :string
#  presentation   :string
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class OptionValue < ActiveRecord::Base
  belongs_to :option_type, touch: true

  with_options presence: true do
    validates :name, uniqueness: { scope: :option_type_id }
    validates :presentation
  end

  has_many :option_value_variants
  has_many :variants, through: :option_value_variants

  def presentation_with_option_type
    "#{option_type.presentation}: #{presentation}"
  end
end
