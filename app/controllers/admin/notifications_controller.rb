class Admin::NotificationsController < AdminController
  before_action :find_notification, only: %w(show destroy activities report)

  def index
    @notifications = Notification.order('created_at DESC').page(params[:page])
    respond_to do |format|
      format.html
      format.json do
        render 'api/v3/notifications/index'
      end
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json do
        render 'api/v3/notifications/show'
      end
    end
  end

  def new
    @notification = Notification.new
    respond_to do |format|
      format.html
      format.json do
        render json: {
          platform: { 'All Platform' => '' }.merge(Device.device_types),
          country: BillingProfile.countries_with_country_code,
          deeplink: {
            'homepage' => 'home',
            'shopping cart' => 'cart',
            'shop' => 'shop',
            'create' => 'create',
            'custom' => ''
          }
        }
      end
    end
  end

  def create
    @notification = Notification.new(admin_permitted_params.notification)
    respond_to do |format|
      format.html do
        if @notification.save
          flash[:notice] = I18n.t('notifications.notice.publish')
          redirect_to admin_notifications_path
        else
          flash[:error] = @notification.errors.full_messages
          render :new
        end
      end
      format.json do
        if @notification.save
          render json: { status: true }
        else
          render text: @notification.errors.full_messages.join(','), status: 400
        end
      end
    end
  end

  def destroy
    @notification.destroy
    render json: { status: true }
  end

  def activities
    @activities = @notification.activities.from_old_to_new.page(params[:page])
  end

  def report
    tracking = @notification.notification_trackings
               .select('date(created_at) as date, count(id) as count')
               .group('date(created_at)')
               .order('date')
    @chart = LazyHighCharts::HighChart.new('graph') do |f|
      f.title(text: 'Notification Report')
      f.xAxis(categories: tracking.map(&:date))
      f.series(name: 'Open count', data: tracking.map(&:count))
      f.chart(defaultSeriesType: 'line')
    end
  end

  private

  def find_notification
    @notification = Notification.find(params[:id] || params[:notification_id])
  end
end
