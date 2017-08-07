class GuanyiSyncOrderService
  attr_reader :trade_form, :purchase_form, :order

  def initialize(order)
    @order = order
    @trade_form = GuanyiTradeForm.new(order)
    @purchase_form = GuanyiPurchaseForm.new(order)
  end

  def sync!
    if valid?
      res = @trade_form.post!
      @order.guanyi_trade_code = res[:code]
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
    ret += @trade_form.errors.values unless @trade_form.valid?
    ret += @purchase_form.errors.values unless @purchase_form.valid?
    ret.flatten
  end
end
