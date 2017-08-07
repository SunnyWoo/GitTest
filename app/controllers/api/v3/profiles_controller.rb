=begin
@apiDefine V3_UserResponse
@apiSuccessExample {json} Response-Example:
{
  "user": {
    "id": 1,
    "name": "User Name",
    "email": "user1@commandp.me",
    "avatars": {
        "s35": "/assets/img_fbdefault.png?v=1440486752",
        "s114": "/assets/img_fbdefault.png?v=1440486752",
        "s154": "/assets/img_fbdefault.png?v=1440486752"
    },
    "avatar_url": "/assets/img_fbdefault.png?v=1440486752",
    "background_url": "/assets/my_gallery/img_gallery_kv-2.png?v=1440486752",
    "gender": null,
    "location": null,
    "works_count": 0,
    "role": "normal",
    "first_name": "Eryn",
    "last_name": "Murazik",
    "mobile": null,
    "mobile_country_code": null,
    "birthday": "2000-10-10"
  }
}
=end
class Api::V3::ProfilesController < ApiV3Controller
  before_action :doorkeeper_authorize!, except: :touch
  before_action -> { doorkeeper_authorize! :touch_user }, only: :touch
  before_action :check_user

=begin
@api {get} /api/me Get user info
@apiUse ApiV3
@apiUse V3_UserResponse
@apiVersion 3.0.0
@apiGroup Profiles
@apiName GetUserinfo
=end
  def show
    @user = current_user
  end

=begin
@api {patch} /api/me/touch Update user timestamp
@apiUse ApiV3
@apiUse V3_UserResponse
@apiVersion 3.0.0
@apiGroup Profiles
@apiName UpdateUserTimestamp
=end
  def touch
    @user = current_user
    @user.touch
    render :show
  end

=begin
@api {patch} /api/me Update current_user info
@apiUse ApiV3
@apiUse V3_UserResponse
@apiVersion 3.0.0
@apiGroup Profiles
@apiName UpdateUserinfo
@apiParam {String} [email] user email
@apiParam {String} [name] user name
@apiParam {String} [location] location
@apiParam {String} [gender] user's sex i.g., male, female, unspecified
@apiParam {String} [first_name] first name
@apiParam {String} [last_name] last name
@apiParam {String} [mobile_country_code] mobile_country_code
@apiParam {String} [birthday] birthday
=end
  def update
    @user = current_user
    @user.update!(permitted_user_attrs)
    render :show
  end

=begin
@api {patch} /api/me/upload_avatar Update user's avatar
@apiUse ApiV3
@apiUse V3_UserResponse
@apiVersion 3.0.0
@apiGroup Profiles
@apiName UpdateUserAvatar
@apiParam {File} [file] image that user wants to upload for repesenting himself
@apiParam {String} [avatar_aid] use attachment api get aid
=end
  def upload_avatar
    @user = current_user
    if params[:avatar_aid].present?
      attachment = Attachment.find_by_aid!(params[:avatar_aid])
      @user.avatar = attachment.file
      attachment.destroy
    elsif params[:file].present?
      @user.avatar = params[:file]
    else
      fail InvalidError, caused_by: 'file or avatar_aid'
    end
    @user.save!
    render :show
  end

  protected

  def permitted_user_attrs
    params.permit(:name, :gender, :email, :location, :first_name, :last_name, :mobile_country_code, :birthday)
  end
end
