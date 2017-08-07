namespace :order_item do
  task enter_print_temp_shelf: :environment do
    OrderItem.where(deliver_complete: true).update_all(aasm_state: 'sublimated')
  end

  task enter_print_package: :environment do
    OrderItem.ransack(deliver_complete_eq: true, order_aasm_state_eq: 'packaged').result.update_all(aasm_state: 'onboard')
  end
end
