class AddImpressionsCountToWorks < ActiveRecord::Migration
  def change
    add_column :works, :impressions_count, :integer
  end
end
