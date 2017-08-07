class AddBackgroundToBdevent < ActiveRecord::Migration
  def change
    add_column :bdevents, :background, :string
  end
end
