class AddPrepareAtToPrintItems < ActiveRecord::Migration
  def change
    add_column :print_items, :prepare_at, :datetime

    PrintItem.find_each do |print_item|
      if print_item.is_reprint?
        prepare_at = print_item.reprint_logs.last.created_at
      else
        prepare_at = print_item.created_at
      end
      print_item.update_column(:prepare_at, prepare_at)
    end
  end
end
