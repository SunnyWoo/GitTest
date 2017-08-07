class Admin::NewsletterSubscriptionsController < AdminController
  def index
    @subscriptions = NewsletterSubscription.page(params[:page])
  end
end
