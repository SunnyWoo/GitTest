class Admin::BillingInfosController < AdminController
  respond_to :html, :json
  before_action :find_order

  VALID_TYPES = %w(address email)

  def edit
    billing_info = @order.billing_info
    @form = Admin::BillingProfileForm.new(billing_info, type: params[:type])
  end

  def update
    billing_info = @order.billing_info
    @form = Admin::BillingProfileForm.new(billing_info)
    @form.attributes = update_params
    if @form.save
      billing_info.billable.update_invoice_info
      flash[:notice] = 'Update Success!'
    else
      flash[:error] = @form.errors.full_messages
    end
    respond_to do |format|
      format.html { redirect_to admin_order_path(@order) }
      format.js { respond_with billing_info }
    end
  end

  def change_country_code
    billing_info = @order.billing_info
    @form = Admin::BillingProfileForm.new(billing_info, country_changed: true)
    @form.attributes = update_params
  end

  private

  def find_order
    @order = Order.find(params[:order_id])
  end

  def update_params
    params.require(:billing_info).permit(
      :name, :email, :phone,
      :address, :city, :state, :dist_code, :province_id,
      :zip_code, :country_code
    )
  end
end
