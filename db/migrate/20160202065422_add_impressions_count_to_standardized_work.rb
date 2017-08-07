class AddImpressionsCountToStandardizedWork < ActiveRecord::Migration
  def change
    add_column :standardized_works, :impressions_count, :integer, default: 0
  end
end
