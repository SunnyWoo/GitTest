class Admin::ActivitiesController < AdminController
  def index
    @activities = Logcraft::Activity.latest_first.page(params[:page])
  end
end
