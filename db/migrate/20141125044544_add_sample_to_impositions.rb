class AddSampleToImpositions < ActiveRecord::Migration
  def change
    add_column :impositions, :sample, :string
  end
end
