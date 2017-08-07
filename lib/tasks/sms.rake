namespace :sms do

  task go_to_pay_you_asshole: :environment do

    atm_content = "權益需知: 聖誕快樂！提醒您使用ATM 訂購我印之商品請儘速至ATM 繳納費用。限今日完成付款聖誕週末可收貨。仍未繳納系統將自動取消訂單。"
    code_content = "權益需知: 聖誕快樂！提醒您使用代碼繳費訂購我印之商品請儘速至代碼繳費繳納費用。限今日完成付款聖誕週末可收貨。仍未繳納系統將自動取消訂單。"

    begin_at = 6.days.ago.midnight
    end_at = Date.yesterday.end_of_day

    atm_orders = Order.ransack({created_at_gteq: begin_at, created_at_lteq: end_at, aasm_state_eq: 'waiting_for_payment', payment_eq: 'neweb/atm'}).result
    code_orders = Order.ransack({created_at_gteq: begin_at, created_at_lteq: end_at, aasm_state_eq: 'waiting_for_payment', payment_eq: 'neweb/mmk'}).result

    sms = SmsGetService.new

    atm_orders.each { |order| sms.execute(order.billing_info.phone, atm_content) }
    code_orders.each { |order| sms.execute(order.billing_info.phone, code_content) }

  end

end

