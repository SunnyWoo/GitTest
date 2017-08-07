class AddPricesToArchivedWorks < ActiveRecord::Migration
  def change
    add_column :archived_works, :prices, :json
  end
end
