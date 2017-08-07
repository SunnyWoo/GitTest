class AddRotateToImpositions < ActiveRecord::Migration
  def change
    add_column :impositions, :rotate, :integer, defualt: 0
    Imposition.update_all(rotate: 0)
  end

  class Imposition < ActiveRecord::Base
  end
end
