class AddShippingFeeSwitchToSiteSettings < ActiveRecord::Migration
  def change
    SiteSetting.create(key: 'ShippingFeeSwitch', value: 'false', description: '是否启用按运送地区计算运费')
  end
end
