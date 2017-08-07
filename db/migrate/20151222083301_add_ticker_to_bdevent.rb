class AddTickerToBdevent < ActiveRecord::Migration
  def up
    Bdevent.add_translation_fields! ticker: :string
  end
  def down
    remove_column :bdevetn_translations, :ticker
  end
end
