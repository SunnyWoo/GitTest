class DeleteExpressFormPackage < ActiveRecord::Migration
  def change
    remove_column :packages, :express_id, :integer
  end
end
