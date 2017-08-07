class DeliverOrder::RemoteInfoService < DeliverOrder::BaseService
  attr_accessor :order, :remote_response
  attr_reader :website, :headers

  def initialize(order)
    @order = order
    super()
  end

  def update
    get("remote_infos/#{order.id}") do |response|
      update_order_remote_info(response)
      update_order_item_remote_info(response)
    end
    true
  rescue => e
    errors.add(e.class.name, message: e.to_s)
    false
  end

  def push
    path = "remote_infos/#{order.remote_id}"
    params = { remote_info: push_order_remote_info }
    put(path, params)
  end

  private

  def update_order_remote_info(response)
    remote_info = {
      'order_no' => response['order_no'],
      'work_state' => response['work_state'],
      'aasm_state' => response['aasm_state']
    }
    order.remote_info = remote_info
    order.save!
  end

  def update_order_item_remote_info(response)
    response['order_items'].each do |order_item_rsp|
      order_item = OrderItem.find(order_item_rsp['id'])
      order_item.remote_info = { 'aasm_state' => order_item_rsp['aasm_state'] }
      order_item.save!
    end
  end

  def push_order_remote_info
    {
      order: { order_no: @order.order_no,
               work_state: @order.work_state,
               aasm_state: @order.aasm_state,
               remote_id: @order.id },
      order_items: push_order_item_remote_info
    }
  end

  def push_order_item_remote_info
    @order.order_items.map do |order_item|
      {
        id: order_item.remote_id,
        aasm_state: order_item.aasm_state
      }
    end
  end
end
