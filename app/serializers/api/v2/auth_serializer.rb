# NOTE: only used in v2 api, remove me later
class Api::V2::AuthSerializer < ActiveModel::Serializer
  attributes :user_id, :auth_token, :email, :username, :first_name, :last_name,
             :role, :mobile, :mobile_country_code, :avatar, :links, :birthday

  def user_id
    object.id
  end

  def avatar
    {
      'use_default_image' => object.avatar.blank?,
      'thumb' => object.avatar.url, # FIXME: it should be a thumbnail url
      'normal' => object.avatar.url
    }
  end

  def username
    object.display_name
  end

  def links
    {
      orders: {
        url: api_my_orders_url,
        accept: 'application/commandp.v1'
      },
      works: {
        url: api_my_works_url,
        accept: 'application/commandp.v1'
      }
    }
  end
end
