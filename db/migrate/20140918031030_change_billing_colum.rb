class ChangeBillingColum < ActiveRecord::Migration
  def change
    add_column :billing_profiles, :type, :string

    BillingProfile.find_each do |bp|
      bp.update(type: 'BillingInfo')
      if bp.billable.present?
        order = bp.billable
        shipping_info = order.build_shipping_info
        shipping_info.address = bp.address
        shipping_info.city = bp.city
        shipping_info.name = bp.name
        shipping_info.phone = bp.phone
        shipping_info.state = bp.state
        shipping_info.zip_code = bp.zip_code
        shipping_info.country = bp.country
        shipping_info.country_code = bp.country_code
        shipping_info.shipping_way = bp.shipping_way
        shipping_info.email = bp.email
        shipping_info.save
      end
    end

  end

  class BillingProfile < ActiveRecord::Base
    self.inheritance_column = 'whatever'
    belongs_to :billable, polymorphic: true
  end
end
