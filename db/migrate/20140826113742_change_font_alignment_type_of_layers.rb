class ChangeFontAlignmentTypeOfLayers < ActiveRecord::Migration

  def up
    change_column :layers, :text_alignment, :string
  end

  def down
    change_column :layers, :text_alignment, :integer
  end

end
