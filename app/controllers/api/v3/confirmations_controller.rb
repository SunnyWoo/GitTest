class Api::V3::ConfirmationsController < ApiV3Controller
  before_action :doorkeeper_authorize!

=begin
@api {post} /api/confirmations Post send confirmation email
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Confirmations
@apiName PostConfirmationEmail
@apiParam {String} email user's email
@apiParam {String} url url to redirect to confirm email page
@apiSuccessExample {json} Response-Example:
{
  "massage": "success",
  "email": "yoona.lin@commandp.com"
}
=end
  def create
    user = User.find_by!(email: params[:email])
    url = params[:url]
    fail InvalidUrlError if url && invalid_url?(url)
    fail AlreadyVerifiedError if user.confirmed?
    fail TooManyRequestError if too_many_request?(user)
    url = "#{Settings.host}/sign_in" if url.nil?
    ConfirmationMailerWorker.perform_async(user.id, url)
    render json: { massage: 'success', email: user.email }, status: :ok
  end

=begin
@api {get} /api/confirmations/:confirmation_token confirm email by confirmation token
@apiUse ApiV3
@apiVersion 3.0.0
@apiGroup Confirmations
@apiName GetConfirmation
@apiParam {String} confirmation_token user's confirmation_token
@apiUse V3_UserResponse
=end
  def show
    @user = User.confirm_by_token(params[:confirmation_token])
    if @user.errors.empty?
      render 'api/v3/profiles/show'
    else
      fail ActiveRecord::RecordInvalid, @user
    end
  end

  private

  def invalid_url?(url)
    !doorkeeper_url?(url) && !white_list_url?(url)
  end

  def doorkeeper_url?(url)
    URI(url).host == URI(doorkeeper_token.application.redirect_uri).host
  end

  def white_list_url?(url)
    white_lists = %w(staging.commandp.com.cn
                     staging.commandp.com
                     commandp.com
                     commandp.com.cn
                     commandp.dev
                     127.0.0.1
                     localhost)
    white_lists.include?(URI(url).host)
  end

  def too_many_request?(user)
    user.confirmation_sent_at && user.confirmation_sent_at + 10.minutes > Time.zone.now
  end
end
