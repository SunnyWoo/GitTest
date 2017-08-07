class AddLocaleToFactory < ActiveRecord::Migration
  def change
    add_column :factories, :locale, :string

    if Region.china?
      Factory.update_all(locale: 'zh-CN')
    else
      Factory.update_all(locale: 'zh-TW')
    end
  end
end
