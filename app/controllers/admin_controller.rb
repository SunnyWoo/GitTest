class AdminController < ApplicationController
  skip_before_action :cn_redirect_to
  before_action :authenticate_admin!
  before_action :check_require_action, :check_view_version, :set_current_admin

  def set_current_admin
    Admin.current_admin = current_admin
  end

  layout 'admin_v2'

  def admin_permitted_params
    @permitted_params ||= AdminPermittedParams.new(params, current_admin)
  end

  helper_method :admin_permitted_params, :shipping_fee

  def shipping_fee
    @shipping_fee = Fee.where(name: '運費').first
  end

  def user_for_paper_trail
    current_admin.id if admin_signed_in?
  end

  def serialization_scope
    {
      admin: current_admin
    }
  end

  protected

  def log_with_current_admin(model)
    if model.respond_to?(:create_activity)
      model.logcraft_user = current_admin
      model.logcraft_source = {channel: 'admin'}
    end
  end

  private

  # Private 確認系統中是否有未設定的資料，如果有該設定而未設定的資料時則將管理者導向設定頁面
  #
  # returns Boolean
  def check_require_action
    return true if session[:action_url] == request.original_url
    return true if !get_request?
    if CurrencyType.count == 0
      set_require_action(url_for([:new, :admin, :currency_type]))
      redirect_to url_for([:new, :admin, :currency_type]), notice: '必須先設定支援貨幣類型，目前沒有任何貨幣類型'
    elsif shipping_fee.currencies.count == 0
      set_require_action(url_for([:edit, :admin, shipping_fee]))
      redirect_to url_for([:edit, :admin, shipping_fee]), notice: '必須先設定運費價格'
    elsif ProductModel.count == 0
      set_require_action(url_for([:new, :admin, :product_model]))
      redirect_to url_for([:new, :admin, :product_model]), notice: '必須先設定商品類型，目前沒有任何商品類型'
    else
      disable_require_action
    end
  end

  def set_require_action(path)
    session[:action_url] = path
  end

  def disable_require_action
    session[:action_url] = nil
  end

  def get_request?
    request.method == 'GET'
  end

  def check_view_version
    if params['_v'].present?
      variant = params['_v']
      request.variant = variant.to_sym
    end
  end
end
