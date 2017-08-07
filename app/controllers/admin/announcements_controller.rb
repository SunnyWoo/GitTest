class Admin::AnnouncementsController < AdminController
  def index
    @search = Announcement.ransack(params[:q])
    @announcements = @search.result(distinct: true).page(params[:page] || 1).order('created_at DESC')
  end

  def new
    @announcement = Announcement.new
  end

  def create
    @announcement = Announcement.new(admin_permitted_params.announcement)
    if @announcement.save
      redirect_to admin_announcements_path
    else
      render :new
    end
  end

  def edit
    @announcement = Announcement.find(params[:id])
  end

  def update
    @announcement = Announcement.find(params[:id])
    if @announcement.update(admin_permitted_params.announcement)
      redirect_to admin_announcements_path
    else
      render :new
    end
  end

  def destroy
    @announcement = Announcement.find(params[:id])
    @announcement.destroy
    redirect_to admin_announcements_path
  end
end
