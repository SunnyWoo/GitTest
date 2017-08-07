class NewsletterSubscriptionsController < ApplicationController
  def create
    subscription = NewsletterSubscription.new(permitted_params.newsletter_subscription)
    subscription.locale = I18n.locale
    subscription.country_code = current_country_code
    if subscription.save
      render json: { status: 'ok', message: t('home.sent-success') }
    else
      render json: {  status: 'Error',
                      message: subscription.errors.full_messages },
                      status: :bad_request
    end
  end
end
