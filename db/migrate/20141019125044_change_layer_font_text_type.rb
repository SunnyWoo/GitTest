class ChangeLayerFontTextType < ActiveRecord::Migration

  def up
    change_column :layers, :font_text, :text
  end

  def down
    change_column :layers, :font_text, :string
  end
end
