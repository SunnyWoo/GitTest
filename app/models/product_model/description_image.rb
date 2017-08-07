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

class ProductModel::DescriptionImage < ActiveRecord::Base
  belongs_to :product, class_name: 'ProductModel'
  mount_uploader :image, DescriptionImageUploader

  validates :image, image_size: { width: { inclusion: [640, 960] } }
end
