# NOTE: not used in v3 api, remove me later
class GuestUserSerializer < ActiveModel::Serializer
  attributes :user_id, :auth_token

  def user_id
    object.id
  end
end
