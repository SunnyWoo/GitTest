class ConvertImpositionsTextToJson < ActiveRecord::Migration
  def up
    change_column :impositions, :definition, 'JSON USING definition::JSON'
  end
end
