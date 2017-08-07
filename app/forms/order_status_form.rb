class OrderStatusForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :email, :order_id

  validates_presence_of :email, :order_id
  validates :email, format: { with: /\S+@\S+/i }
end