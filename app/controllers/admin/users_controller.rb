class Admin::UsersController < Admin::ResourcesController
  before_action :find_user, only: [:show, :publish_notification, :clear_mobile]
  def index
    if params[:q].present?
      q = { name_or_email_or_mobile_cont: params[:q] }
      @search = model_class.ransack(q)
      @resources = @search.result.order('id DESC').page(params[:page])
    end
  end

  def show
    @activities = @user.activities.ordered.page(params[:page])
  end

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    params[:user].delete(:password_confirmation) if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
    super
  end

  def clear_mobile
    mobile = @user.mobile
    @user.update_attribute(:mobile, nil)
    log_with_current_admin @user
    @user.create_activity(:clear_mobile, mobile: mobile)
    flash[:notice] = I18n.t('users.clear_mobile.notice')
    redirect_to :back
  end

  def publish_notification
    user_notification = UserNotificationForm.new(params[:user_notification_form])
    if user_notification.valid?
      UserNotificationPublisher.perform_in(30.second, @user.id, user_notification.device_id, user_notification.message)
      log_with_current_admin @user
      @user.create_activity(:publish_notification, message: user_notification.message, device_id: user_notification.device_id)
      flash[:notice] = I18n.t('notifications.notice.publish')
    else
      flash[:error] = user_notification.errors.full_messages
    end
    redirect_to action: :show
  end

  private

  def find_user
    @user = User.find(params[:id])
  end
end
