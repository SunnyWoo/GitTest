class OrdersController < ApplicationController
  def order_status
    redirect_to order_history_users_path if user_signed_in?
    set_meta_tags title: t('order_status.title'),
                  description: I18n.t('order_status.description'),
                  og: {
                    title: "#{t('site.name')} | #{t('order_status.title')}",
                    description: I18n.t('order_status.description')
                  }
  end

  def check_order_status
    email = params[:order_status_form][:email]
    order_id = params[:order_status_form][:order_id]
    if email.present? && order_id.present?
      order = Order.viewable.find_by(order_no: order_id)
      if order && order.billing_info_email == email.downcase
        OrderMailer.delay.receipt_with_status(order.user_id, order.id)
        flash[:notice] = "Order summary send"
      else
        flash[:error] = "Order or E-mail Error"
      end
    else
      flash[:error] = "E-mail or Order ID can't be blank"
    end
    redirect_to order_status_orders_path
  end
end
