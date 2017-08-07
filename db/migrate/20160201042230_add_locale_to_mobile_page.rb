class AddLocaleToMobilePage < ActiveRecord::Migration
  def change
    add_column :mobile_pages, :country_code, :string
    if Region.china?
      MobilePage.update_all(country_code: 'CN')
    else
      MobilePage.update_all(country_code: 'TW')
    end
  end
end
