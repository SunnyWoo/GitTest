# == Schema Information
#
# Table name: product_model_description_images
#
#  id         :integer          not null, primary key
#  product_id :integer
#  image      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ProductModel::DescriptionImage, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
