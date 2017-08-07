class AddColumnToCurrencyTypes < ActiveRecord::Migration
  def change
    add_column :currency_types, :precision, :integer, default: 0

    ct = CurrencyType.find_by(code: 'USD')
    ct.update!(precision: 2) if ct.present?
  end
end
