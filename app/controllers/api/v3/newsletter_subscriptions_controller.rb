class Api::V3::NewsletterSubscriptionsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {post} /api/newsletter_subscriptions Create Newsletter Subscription
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup NewsletterSubscriptions
@apiName CreateNewsletterSubscription
@apiParam {String} email request E-mail
@apiSuccessExample {json} Response-Example:
 {
    "newsletter_subscription" => {
      "id" => 1,
      "email" => "xxx@xxx.xx"
    }
 }
=end
  def create
    @newsletter_subscription = NewsletterSubscription.create!(newsletter_subscription_params)
    render 'api/v3/newsletter_subscriptions/show', status: :created
  end

  private

  def newsletter_subscription_params
    params.permit(:email).merge(locale: I18n.locale,
                                country_code: current_country_code)
  end
end
