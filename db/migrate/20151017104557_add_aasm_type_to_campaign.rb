class AddAasmTypeToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :aasm_state, :string, default: 'is_closed'
  end
end
