class RemoveAasmStateIndex < ActiveRecord::Migration
  def change
    remove_index :standardized_works, column: :aasm_state
    remove_index :promotions, column: :aasm_state
  end
end
