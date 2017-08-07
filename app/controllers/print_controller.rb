class PrintController < ApplicationController
  include Pundit
  before_action :authenticate_factory_member!
  layout 'print'

  rescue_from Pundit::NotAuthorizedError, with: :unauthorized

  def print_permitted_params
    @permitted_params ||= PrintPermittedParams.new(params)
  end
  helper_method :print_permitted_params

  def current_factory
    current_factory_member.factory if current_factory_member
  end
  helper_method :current_factory

  alias_method :pundit_user, :current_factory_member

  protected

  def user_for_paper_trail
    current_admin.id if admin_signed_in?
  end

  def log_with_print_channel(model, user: current_factory_member)
    model.logcraft_source = { channel: 'print' }
    return unless model.respond_to?(:create_activity)
    model.logcraft_user = user
    model.logcraft_source = { channel: 'print',
                              ip: request.remote_ip,
                              os_type: user_agent.platform || 'Unknown',
                              os_version: user_agent.os || 'Unknown' }
  end

  # 若有登入 admin 紀錄 admin 的 current_admin
  def log_with_admin_or_print(model)
    user = admin_signed_in? ? current_admin : current_factory_member
    log_with_print_channel(model, user: user)
  end

  def set_locale
    I18n.locale = 'zh-TW'
  end

  def unauthorized
    respond_to do |format|
      format.html do
        redirect_to request.referrer || print_print_path, alert: '沒有權限進行此操作.'
      end
      format.js do
        render js: "alert('沒有權限進行此操作.')"
      end
    end
  end
end
