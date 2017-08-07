class Store::LayoutForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :title, :description
end
