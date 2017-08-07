# == Schema Information
#
# Table name: option_value_variants
#
#  id              :integer          not null, primary key
#  variant_id      :integer
#  option_value_id :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class OptionValueVariant < ActiveRecord::Base
  belongs_to :option_value
  belongs_to :variant
end
