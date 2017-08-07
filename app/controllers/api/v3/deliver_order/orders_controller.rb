class Api::V3::DeliverOrder::OrdersController < ApiV3Controller
  before_action :doorkeeper_authorize!

  def create
    # unless the_worker_exist?
    #   CreateDeliveryOrderWorker.perform_async(params[:query])
    # end
    CreateDeliveryOrderWorker.perform_async(params[:query])
    render json: { status: 'success' }, status: :ok
  end

  def cancel
    order = Order.find_by!(remote_id: params[:order_id])
    order.update(aasm_state: 'canceled')
    render json: { status: 'success' }, status: :ok
  end

  def single_item_infos
    orders = Order.where('delivered_at > ?', Time.zone.now.prev_month.beginning_of_month)
    result = orders.each_with_object([]) do |order, arr|
      arr << { order_id: order.id, single_item: order.single_item? }
    end

    render json: result, status: :ok
  end

  private

  def the_worker_exist?
    exist_in_workers? || exist_in_queue? || exist_in_retries?
  end

  # 执行中
  def exist_in_workers?
    Sidekiq::Workers.new.select do |_process_id, _thread_id, work|
      work['payload']['class'] = 'CreateDeliveryOrderWorker' &&
                                 work['payload']['args'][0]['order_id'].to_s == params[:query][:order_id].to_s
    end.present?
  end

  # 队列中
  def exist_in_queue?
    Sidekiq::Queue.new('deliver_order').select do |job|
      job.klass == 'CreateDeliveryOrderWorker' && job.args[0]['order_id'].to_s == params[:query][:order_id].to_s
    end.present?
  end

  # 重试中
  def exist_in_retries?
    Sidekiq::RetrySet.new.select do |job|
      job.klass == 'CreateDeliveryOrderWorker' && job.args[0]['order_id'].to_s == params[:query][:order_id].to_s
    end.present?
  end
end
