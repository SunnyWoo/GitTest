class Api::V2::Admin::UserSerializer < ActiveModel::Serializer
  attributes :id, :role, :email, :name, :username, :mobile, :avatar, :auth_token

  def avatar
    img = object.avatar
    {
      thumb: img.url,
      normal: img.url,
      s35: img.s35.url,
      s114: img.s114.url,
      s154: img.s154.url
    }
  end
end
