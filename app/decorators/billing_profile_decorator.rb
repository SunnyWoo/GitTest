class BillingProfileDecorator < ApplicationDecorator
  delegate_all
  delegate :dist_code, :dist, to: :address_data

  def province
    address_data.try(:province) || source.province_name
  end

  alias_method :province_name, :province

  def province_id
    address_data.province_id || source.province_id
  end
end
