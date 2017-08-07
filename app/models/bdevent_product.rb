# == Schema Information
#
# Table name: bdevent_products
#
#  id         :integer          not null, primary key
#  bdevent_id :integer
#  product_id :integer
#  image      :string(255)
#  info       :json
#  position   :integer
#  created_at :datetime
#  updated_at :datetime
#

class BdeventProduct < ActiveRecord::Base
  belongs_to :product, class_name: 'ProductModel', foreign_key: :product_id
  belongs_to :bdevent

  validates :bdevent_id, uniqueness: { scope: :product_id }

  store_accessor :info, %w(title)
  mount_uploader :image, BdeventWorkUploader
  acts_as_list scope: :bdevent

  default_scope { order('position DESC') }

  def product_title
    title.present? ? title : product.name
  end

  def product_image
    image.present? ? image : product.placeholder_image
  end
end
