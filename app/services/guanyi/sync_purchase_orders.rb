class Guanyi::SyncPurchaseOrders
  extend Guanyi::MonthlyOrders

  attr_reader :purchase_form, :order

  def self.sync_orders
    orders_slices = orders.each_slice(100).to_a
    orders_slices.each_with_index do |orders_slice, index|
      orders_slice.each do |order|
        sync(order)
      end
      sleep 60 if orders_slices[index + 1]
    end
  end

  def self.sync(order)
    new(order).sync!
  rescue => e
    SlackNotifier.send_msg("同步采购订单#{order.id}:  #{e}")
  end

  def initialize(order)
    @order = order
    @purchase_form = GuanyiPurchaseForm.new(order)
  end

  def sync!
    if valid?
      res = @purchase_form.post!
      @order.guanyi_purchase_code = res[:code]
      @order.save!
    else
      fail ArgumentError, errors.join(', ')
    end
  end

  def valid?
    errors.blank?
  end

  protected

  def errors
    ret = []
    ret += @purchase_form.errors.values unless @purchase_form.valid?
    ret.flatten
  end
end
