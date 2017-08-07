class Api::V1::UsersController < ApiController
  # Create Guest User
  #
  # Url : /api/users
  #
  # RESTful : POST
  #
  # Get Example
  #   /api/users
  #
  # Return Example
  #  {
  #    "user_id":"1",
  #    "auth_token":"850d703561ab164165da05d8ce0a2f2f"
  #  }
  #
  # @return [JSON] status 200

  def create
    @user = User.new_guest
    render json: @user, serializer: GuestUserSerializer, root: false
  end
end
