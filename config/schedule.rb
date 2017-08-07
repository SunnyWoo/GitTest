set :output, error: 'log/cron_error.log', standard: 'log/cron.log'
env :PATH, ENV['PATH']

@region = ENV['REGION'] == 'china' ? 'china' : 'global'
job_type :rake, "cd :path && :environment_variable=:environment REGION=#{@region} bundle exec rake :task --silent :output"

every 1.hour do
  rake 'report:update'
end

if @environment == 'production'
  every 1.day, at: '9am,6pm' do
    rake 'report:daily_orders_email'
  end

  every 1.day, at: '8:30am' do
    rake 'report:last_month_orders_email'
  end

  every 1.day, at: '3am' do
    runner 'Coupon.expired.update_all(is_enabled: false)'
  end

  every :hour do
    runner 'PatrolService.new.make_sure_deliverd_orders_have_coupon'
  end

  every :hour do
    runner 'PatrolService.new.print_item_quantity_check'
  end

  every :hour, at: 1 do # Make sure the task won't be missed due to clock issue
    runner 'ScheduledEvent.trigger!'
  end

  every :monday, at: '10am' do
    rake 'b2b2c_order:weekly_report'
  end

  every 1.day, at: '10am' do
    rake 'b2b2c_order:daily_report'
  end
  if @region == 'china'
    every '0 6 1 * *' do # First day of each month at 6 am
      rake 'report:monthly_sublimated_orders'
      rake 'report:monthly_print_items'
    end

    every 1.day, at: '10:00 pm' do
      rake 'export_order:daily_ship_orders'
      rake 'report:daily_print_items'
    end
  end
end

every 1.day, at: '11:00 pm' do
  rake '-s sitemap:refresh:no_ping'
end

every 1.day, at: '12:00 pm' do
  rake '-s order:reconciliation'
end

every 1.day, at: '18:00 pm' do
  rake '-s order:auto_cancel'
end

every 1.day, at: '00:00 am' do
  rake '-s coupon:fallback'
end

every 1.day, at: '00:00 am' do
  rake 'daily_record:store_order_sticker_info'
end

every 1.week, at: '11:30 pm' do
  rake 'i18n_robot:save_from_redis_to_db'
end

if @environment == 'production' && @region == 'global'
  every :hour do
    rake '-s invoice:download_bankpro_file'
  end

  every 1.day, at: '3:55pm' do
    rake '-s order:shipping_to_tw_create_invoice'
  end

  every :hour do
    rake '-s order:invoice_ready_upload_create_invoice'
  end

  every 1.week, at: '12:00 pm' do
    rake 'desinger_product:generates_week_sell_report'
  end
end
