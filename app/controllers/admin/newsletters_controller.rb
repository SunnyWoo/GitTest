class Admin::NewslettersController < AdminController
  before_action :find_newsletter, only: [:show, :destroy, :get_report,
                                         :send_mail, :edit, :update]
  before_action :find_mailing_list, only: [:new, :create, :edit, :update]
  def index
    @search = Newsletter.ransack(params[:q])
    @newsletters = @search.result.order('id DESC').page(params[:page])
  end

  def show
  end

  def new
    @newsletter = Newsletter.new(delivery_at: (Time.zone.now + 30.minutes).strftime('%F %T'))
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)
    if @newsletter.save
      redirect_to admin_newsletter_path(@newsletter),
                  notice: t('helpers.submit.create', model: @newsletter.class.name)
    else
      flash[:error] = @newsletter.errors.full_messages
      render :new
    end
  end

  def edit
  end

  def update
    if @newsletter.update_attributes(newsletter_params)
      redirect_to admin_newsletter_path(@newsletter),
                  notice: t('helpers.submit.update', model: @newsletter.class.name)
    else
      render :edit
    end
  end

  def destroy
    @newsletter.destroy
    redirect_to admin_newsletters_path,
                notice: t('helpers.submit.destory', model: @newsletter.class.name)
  end

  def get_report
    @newsletter.mailgun_campaign.get_report
    redirect_to admin_newsletters_path
  end

  def send_mail
    @newsletter.create_mailgun_campaign
    redirect_to admin_newsletters_path, notice: t('newsletter.sent')
  end

  private

  def find_newsletter
    @newsletter = Newsletter.find(params[:id])
  end

  def newsletter_params
    params.require(:newsletter).permit([:name, :delivery_at, :subject, :content, :locale, filter: []])
  end

  def find_mailing_list
    mailing_list = $mailgun.lists.list.select { |list| list['address'].match(Settings.mailgun.domain) }
    @mailing_list_options = mailing_list.map { |list| ["#{list['name']}(#{list['members_count']})", list['address']] }
  end
end
