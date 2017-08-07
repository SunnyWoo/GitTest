class AddAasmStateToChangePriceEvents < ActiveRecord::Migration
  def change
    add_column :change_price_events, :aasm_state, :string
  end
end
