class ChangeColumnTemplateFromIntToStrInMobileUi < ActiveRecord::Migration
  def change
    change_column :mobile_uis, :template, :string
  end
end
