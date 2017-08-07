=begin
@apiDefine AdminUserResponse
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    "user" => {
      "id" => 1,
      "role" => "normal",
      "email" => "user1@commandp.me",
      "name" => "User Name",
      "username" => "User Name",
      "mobile" => "1394123454",
      "avatar" => {
        "thumb" => "/assets/img_fbdefault.png?v=1438926249",
        "normal" => "/assets/img_fbdefault.png?v=1438926249",
        "s35" => "/assets/img_fbdefault.png?v=1438926249",
        "s114" => "/assets/img_fbdefault.png?v=1438926249",
        "s154" => "/assets/img_fbdefault.png?v=1438926249"
      },
      "auth_token" => nil
    }
  }
=end
class Api::V2::Admin::UsersController < ApiV2Controller
  before_action :find_user, only: [:show, :update, :destroy]

=begin
@api {post} /api/admin/users Creat user
@apiUse AdminUserResponse
@apiVersion 2.0.0
@apiGroup AdminUsers
@apiPermission admin
@apiName AdminCreateUser
@apiParam (User) {Object} user User hash object
@apiParam (User) {String} user.email Email
@apiParam (User) {String} user.name Name
@apiParam (User) {String="guest","normal"} [user.role] User role
@apiParam (User) {String} user.password Password
@apiParam (User) {String} user.password_confirmation Password confirmation
@apiParam (User) {String} user.mobile User mobile
=end
  def create
    @user = User.new(user_params)
    @user.save!
    render json: @user, serializer: Api::V2::Admin::UserSerializer
  end

=begin
@api {get} /api/admin/users/:id Retrieve user info
@apiUse AdminUserResponse
@apiVersion 2.0.0
@apiGroup AdminUsers
@apiPermission admin
@apiName AdminShowUser
=end
  def show
    render json: @user, serializer: Api::V2::Admin::UserSerializer
  end

=begin
@api {put} /api/admin/users/:id Update user
@apiUse AdminUserResponse
@apiVersion 2.0.0
@apiGroup AdminUsers
@apiPermission admin
@apiName AdminUpdateUser
@apiParam (User) {Object} user User hash object
@apiParam (User) {String} [user.email] Email
@apiParam (User) {String} [user.name] Name
@apiParam (User) {String="guest","normal"} [user.role] User role
@apiParam (User) {String} [user.password] Password
@apiParam (User) {String} [user.password_confirmation] Password confirmation
@apiParam (User) {String} [user.mobile] User mobile
=end
  def update
    @user.update_attributes!(user_params)
    render json: @user, serializer: Api::V2::Admin::UserSerializer
  end

=begin
@api {delete} /api/admin/users/:id Delete user
@apiVersion 2.0.0
@apiGroup AdminUsers
@apiPermission admin
@apiName AdminDeleteUser
@apiSuccessExample {json} Success-Response:
  HTTP/1.1 200 OK
  {
    msg: "User destroyed!"
  }
=end
  def destroy
    @user.destroy
    render json: { msg: 'User destroyed!' }, status: :ok
  end

  protected

  def find_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :name, :role, :password, :password_confirmation, :mobile)
  end
end
