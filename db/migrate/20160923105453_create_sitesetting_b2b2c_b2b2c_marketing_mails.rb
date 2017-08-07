class CreateSitesettingB2b2cB2b2cMarketingMails < ActiveRecord::Migration
  def change
    SiteSetting.create key: 'b2b2c_marketing_mails', value: 'jo.lin@commandp.com', description: '承辦b2b2_orders報表的人員，若email超過1個請用,隔開'
  end
end
