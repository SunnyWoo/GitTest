class Api::V2::ConfirmationsController < ApiV2Controller
=begin
@api {post} /api/confirmation Send email for confirmation
@apiVersion 2.0.0
@apiGroup Confirmations
@apiName CreateConfirmation
@apiParam {String} email user's email when he signed up
@apiParam {String} url url to redirect to confirm email page
@apiSuccessExample {json} Response-Example:
{
  "massage": "success",
  "email": "yoona.lin@commandp.com"
}
=end
  def create
    user = User.find_by!(email: params[:email])
    white_lists = %w(staging.commandp.com.cn
                     staging.commandp.com
                     commandp.com
                     commandp.com.cn
                     commandp.dev
                     127.0.0.1
                     localhost)
    url = params[:url]
    fail InvalidUrlError if url && !white_lists.any? { |host| URI(url).host == host }
    ConfirmationMailerWorker.perform_async(user.id, url)
    render json: { massage: 'success', email: user.email }, status: :ok
  end

=begin
@api {get} /api/confirmation confirm email by confirmation token
@apiVersion 2.0.0
@apiGroup Confirmations
@apiName ShowConfirmation
@apiParam {String} confirmation_token user's confirmation_token
@apiUse AuthSuccess
=end
  def show
    user = User.confirm_by_token(params[:confirmation_token])
    if user.errors.empty?
      render json: user, serializer: Api::V2::AuthSerializer
    else
      fail ActiveRecord::RecordInvalid.new user
    end
  end
end
