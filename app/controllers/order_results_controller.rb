class OrderResultsController < ApplicationController
  before_action :set_device_type
  before_action :check_signed_in
  before_action :find_order

  DELAYED_PAYMENTS = %w(cash_on_delivery neweb/alipay neweb/atm neweb/mmk)

  def show
    if @order.paid?
      render @order.payment == 'redeem' ? :redeem : :success
    else
      if DELAYED_PAYMENTS.include?(@order.payment_method) && @order.aasm_state == 'waiting_for_payment'
        render :waiting
      else
        render_failure
      end
    end
  end

  private

  def neweb_mpp_fail_message
    neweb_bank_response ||= YAML.load_file('config/neweb_mpp_respons_code.yml')
    extra_info = @order.activities.where(key: 'pay_fail').ordered.first.try(:extra_info)
    return I18n.t('errors.payment_invalid') unless extra_info.present?
    bank_code = extra_info['BankResponseCode'].split('/')[1].to_i
    description_message = neweb_bank_response['code'][bank_code]
    "錯誤訊息: #{description_message}，錯誤代碼: #{extra_info['BankResponseCode']}/#{extra_info['PRC']}/#{extra_info['SRC']}"
  end

  def render_failure
    @error_message = case @order.payment_method
                     when 'neweb_mpp' then neweb_mpp_fail_message
                     else params[:error_message]
                     end
    cart = CartSession.new(controller: self, user_id: current_user.id)
    cart.reload_order(@order)
    render :failure
  end

  def check_signed_in
    render_404 unless user_signed_in?
  end

  def find_order
    @order = current_user.orders.viewable.find_by!(order_no: params[:id])
  end
end
