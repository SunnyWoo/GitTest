class Print::PrintItemsController < PrintController
  before_action :set_delayed_time, only: %i(delayed delayed_history)
  before_action :check_print_type, only: :reprint

  def reprint
    authorize PrintItem, :reprint?
    print_item = PrintItem.find(params[:print_item_id])
    errors = valid_print_history_params(print_history_params)
    if errors.blank? && print_item.present?
      print_item.reprint!(print_history_params)
      log_reprint_activity(print_item.reload)
      redirect_to request.referer || print_print_path, flash: {
        notice: "訂單編號：#{print_item.order.order_no} ,訂單品項 timestamp_no：#{print_item.timestamp_no} ,已經加入重新列印清單!"
      }
    else
      redirect_to request.referer || print_print_path, flash: {
        error: errors || '無法加入重印清單, PrintItem Id 錯誤.'
      }
    end
  end

  def delayed
    authorize PrintItem, :delayed?
    search = { order_item_order_aasm_state_eq: 'paid',
               order_item_order_order_no_or_id_or_timestamp_no_eq: params[:number] }
    includes = { order_item: { itemable: [], order: [:notes] } }
    states = %i(pending uploading printed)
    @product_models = ProductModel.includes(:translations, category: [:translations]).all
    @print_items = PrintItem.where('prepare_at <= ?', @delayed_time)
                            .with_states(states)
                            .includes(includes)
                            .ransack(search).result
                            .order('prepare_at')
                            .paginate(page: params[:page], per_page: 500)
  end

  # 历史记录需要包含已经热转印完成的迟到订单
  # 包含以下记录
  #  1：没有热转印：当前时间 - 进入工作站时间 > 72小时 and orders.aasm_state = 'paid'
  #  2：热转印完成：热转印时间 - 进入工作站时间 > 72小时
  def delayed_history
    authorize PrintItem, :delayed?
    search = { created_at_gteq: params[:created_at_gteq], created_at_lteq: params[:created_at_lteq] }
    includes = { order_item: :order }
    states = %i(pending uploading printed)
    conditions = "(print_items.sublimated_at - print_items.prepare_at) >= CAST('72 hour' AS INTERVAL)"
    conditions += " OR (print_items.prepare_at <= :delayed_time and print_items.aasm_state in (:states) and orders.aasm_state = 'paid')"
    print_items = PrintItem.joins(includes)
                           .where(conditions, delayed_time: @delayed_time, states: states)
                           .ransack(search).result
                           .order('print_items.prepare_at')
    respond_to do |format|
      format.csv do
        send_data mark_csv_data(PrintService.export_delayed_history_csv(print_items)),
                  disposition: file_disposition('遲到歷史記錄', 'csv')
      end
    end
  end

  def reprint_list
    authorize PrintItem, :reprint_list?
    search = { prepare_at_gteq: params[:prepare_at_gteq], prepare_at_lteq: params[:prepare_at_lteq] }
    includes = [{ order_item: :order }, :print_histories]
    @product_models = ProductModel.includes(:translations, category: [:translations]).all
    @print_items = PrintItem.includes(includes)
                            .where.not(print_histories: { print_type: 'print' })
                            .order(prepare_at: :asc)
                            .ransack(search).result
                            .paginate(page: params[:page], per_page: 500)
  end

  def reprint_history
    authorize PrintItem, :reprint_list?
    search = { prepare_at_gteq: params[:prepare_at_gteq], prepare_at_lteq: params[:prepare_at_lteq] }
    print_histories = PrintHistory.where.not(print_type: 'print').order(prepare_at: :asc)
                                  .ransack(search).result
    respond_to do |format|
      format.csv do
        send_data mark_csv_data(PrintService.export_reprint_history_csv(print_histories)),
                  disposition: file_disposition('重印歷史記錄', 'csv')
      end
    end
  end

  def qualified_report
    authorize PrintItem, :qualified_report?
    return if params[:qualified_at_gteq].blank?
    @report_presenter = Print::QualifiedReportPresenter.new(params)
    respond_to do |format|
      format.html
      format.csv do
        send_data mark_csv_data(@report_presenter.csv_data),
                  disposition: file_disposition(@report_presenter.csv_file_name, 'csv', with_date: false)
      end
    end
  end

  def schedule
    authorize PrintItem, :schedule?
    @schedule_presenter = Print::PrintItemSchedulePresenter.new(params)
  end

  def disable_schedule
    authorize PrintItem, :disable_schedule?
    @print_item = PrintItem.find(params[:id])
    @print_item.disable_schedule
  end

  private

  def log_reprint_activity(print_item)
    log_with_print_channel current_factory
    current_factory.create_activity(:reprint,
                                    message: "print_item_id:#{print_item.id}",
                                    print_item_id: print_item.id)
    order = print_item.order
    log_with_admin_or_print order
    order.create_activity(:reprint,
                          message: "print_item_id:#{print_item.id}",
                          print_item_id: print_item.id,
                          order_item_id: print_item.order_item_id)

    history = print_item.print_histories.last
    history.create_activity(:create,
                            user: current_factory_member,
                            message: "print_item_id:#{print_item.id}",
                            print_item_id: print_item.id,
                            order_item_id: print_item.order_item_id)
  end

  def set_delayed_time
    delayed_hours = params[:delayed_hours] || 72
    @delayed_time = Time.zone.now - delayed_hours.to_i.hours
  end

  def print_history_params
    params.require(:print_history).permit(:print_type, :reason)
  end

  def valid_print_history_params(print_history_params)
    print_history = PrintHistory.new(print_history_params)
    print_history.valid?
    print_history.errors.full_messages
  end

  # 上傳卡單重印
  def check_print_type
    if params[:upload_fail]
      params[:print_history] = { print_type: 'upload_fail_reprint', reason: '上傳卡單重印' }
    end
  end
end
