# NOTE: not used in v3 api, remove me later
class AuthSerializer < ActiveModel::Serializer
  attributes :user_id, :auth_token, :role, :links

  def user
    object.user
  end

  def user_id
    user.id
  end

  def role
    user.role
  end

  def auth_token
    user.auth_token
  end

  def links
    [
      {
        role: 'orders',
        url: api_my_orders_url,
        accept: 'application/commandp.v1'
      },{
        role: 'works',
        url: api_my_works_url,
        accept: 'application/commandp.v1'
      }

    ]
  end
end
