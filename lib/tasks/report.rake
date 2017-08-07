namespace :report do
  task update: :environment do
    ReportService.execute_all_updates
  end

  task daily_orders_email: :environment do
    ReportMailer.orders.deliver
  end

  task last_month_orders_email: :environment do
    today = Time.zone.today
    last_month = today.last_month
    start_date = last_month.beginning_of_month.strftime('%Y-%m-%d')
    end_date = today.beginning_of_month.strftime('%Y-%m-%d')
    ReportMailer.range_orders(start_date, end_date).deliver
  end

  task :range_orders, [:start_date, :end_date] => :environment do |_t, args|
    now = Time.zone.now
    args.with_defaults(
      start_date: now.beginning_of_month.strftime('%Y-%m-%d'),
      end_date: now.end_of_month.strftime('%Y-%m-%d')
    )
    ReportMailer.range_orders(args.start_date, args.end_date).deliver
  end

  task product_models: :environment do
    column_titles = %w(分類代碼 分類名稱 產品化碼 產品名稱)
    res = CSV.generate do |csv|
      csv << column_titles
      ProductModel.available.find_each do |pm|
        cate = pm.category
        csv << [cate.key, cate.name(:'zh-CN'), pm.key, pm.name(:'zh-CN')]
      end
    end
    puts res
  end

  task monthly_sublimated_orders: :environment do
    today = Time.zone.today
    last_month = today.last_month
    start_date = last_month.beginning_of_month
    end_date = today.beginning_of_month
    # 先以 sublimated (已熱轉印) 作為入倉依據
    # TODO: 可能會轉成 qualified(已質檢通過) 作為入倉依據
    print_item_ids = Logcraft::Activity.where(key: 'state_changed', trackable_type: 'PrintItem')
                                       .where("extra_info->>'state_change' = ?", %w(printed sublimated).to_json)
                                       .between_times(start_date, end_date).pluck(:trackable_id)

    order_item_ids = PrintItem.where(id: print_item_ids).pluck(:order_item_id)
    order_ids = OrderItem.where(id: order_item_ids).pluck(:order_id)
    orders = Order.where(id: order_ids)
    ReportMailer.specified_orders(orders, subject: "#{last_month.month}月份入倉訂單報表").deliver
  end

  task daily_print_items: :environment do
    ReportMailer.daily_print_items.deliver
    # 9月26日多发送国庆特别版月报表，之后可删除
    if Time.zone.now.to_date.to_s == '2016-09-26'
      ReportMailer.monthly_print_items(Time.new(2016, 9, 01).in_time_zone, Time.new(2016, 9, 25).in_time_zone).deliver
    end
  end

  task monthly_print_items: :environment do
    # 11月1日发送国庆特别版月报表，之后可删除
    if Time.zone.now.to_date.to_s == '2016-11-1'
      ReportMailer.monthly_print_items(Time.new(2016, 9, 26).in_time_zone, Time.new(2016, 10, 31).in_time_zone).deliver
    else
      ReportMailer.monthly_print_items.deliver
    end
  end
end
