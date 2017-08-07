profile = BillingProfileDecorator.new(profile) unless profile.is_a?(BillingProfileDecorator)
cache_json_for json, profile do
  json.call(profile,
            :id, :address, :dist, :dist_code, :city, :name, :phone, :state, :province_id, :province, :province_name,
            :zip_code, :country, :created_at, :updated_at, :country_code, :shipping_way,
            :email, :address_name)
end
