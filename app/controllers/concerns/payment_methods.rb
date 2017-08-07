module PaymentMethods
  extend ActiveSupport::Concern

  included do
    before_action :doorkeeper_authorize!, :check_user
    before_action :find_order
  end

  def free_check(order)
    free = (order.price == 0)
    order.pay! if free
    order.create_activity(:pay_success, message: 'free_check', payment_method: order.try(:payment_method))
    free
  end

  def check_url(*urls)
    urls.each do |url|
      fail InvalidUrlError if url && URI(url).host != URI(doorkeeper_token.application.redirect_uri).host
    end
  end

  protected

  def find_order
    @order = current_user.orders.find_by!(uuid: params[:uuid]) if params[:uuid].present?
    @order = current_user.orders.find_by!(order_no: params[:order_no]) if params[:order_no].present?
    fail ActiveRecord::RecordNotFound unless @order
  end
end
