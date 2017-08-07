class AddTypeToImpositions < ActiveRecord::Migration
  def change
    add_column :impositions, :type, :string
    add_index :impositions, [:id, :type]

    Imposition.update_all(type: 'Imposition::Asgard')
  end

  class Imposition < ActiveRecord::Base
  end

  Imposition.inheritance_column = :whatever
end
