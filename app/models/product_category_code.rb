# == Schema Information
#
# Table name: product_category_codes
#
#  id          :integer          not null, primary key
#  description :string(255)
#  code        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class ProductCategoryCode < ActiveRecord::Base
  include UpcaseCode

  has_one :category, class_name: 'ProductCategory', foreign_key: :category_code_id
  has_many :products, class_name: 'ProductModel', through: :category

  validates :code, uniqueness: true, presence: true, length: { is: 2 }
end
