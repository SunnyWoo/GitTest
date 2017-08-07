class BillingProfileForm
  include ActiveModel::Model
  include ActiveModel::Validations

  VALID_TYPES = %w(address email).freeze

  attr_reader :profile, :type
  delegate :billable, :id, :persisted?,
           :name, :email, :phone,
           :address, :city, :state, :zip_code, :country_code,
           to: :profile

  def initialize(profile, type = 'address')
    @profile = profile
    @address = profile.address_data
    @type = VALID_TYPES.include?(type) ? type : 'email'
  end

  def attributes=(attrs)
    @profile.attributes = attrs.except(:province, :province_id, :dist, :dist_code)
    address = Address.new(attrs)
    @profile.address_data = address if address.present?
  end

  def save
    valid? && @profile.save
  end

  def save!
    valid? && @profile.save!
  end
end
