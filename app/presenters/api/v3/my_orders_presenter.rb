class Api::V3::MyOrdersPresenter
  include Enumerable

  delegate :each, :size, to: :orders

  def initialize(user, scope = nil)
    @user = user
    scope = scope.in?(valid_scopes) && scope
    @resources = base_resources.includes(:adjustments, order_items: :adjustments).order('orders.created_at DESC')
    @resources = @resources.send(scope) if scope
  end

  def orders
    @orders ||= @resources.decorate(with: Api::V3::OrderDecorator)
  end

  def etag
    flag = base_resources.select('COUNT(*) total, MAX(orders.updated_at) max_id').to_a.first

    "api/v3/orders/#{@user.id}/#{flag.total}-#{flag.max_id.try(:utc).try(:to_s, :number)}"
  end

  private

  def valid_scopes
    Order.aasm.states.map { |s| s.name.to_s }
  end

  def base_resources
    @user.orders.viewable
  end
end
