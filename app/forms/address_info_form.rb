class AddressInfoForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :id, :address, :city, :name, :phone, :state, :zip_code,
  :country, :billable_id, :billable_type, :created_at, :updated_at,
  :country_code, :shipping_way, :email, :type, :address_name, :memo, :province_id, :address_data

  validates_presence_of :address, :city, :name, :phone, :zip_code, :address_name
  validates_presence_of :email
  validates :email, format: { with: /\S+@\S+\.\S+/i }
end
