# NOTE: only used in v2 api, remove me later
class Api::V2::NotificationTrackingSerializer < ActiveModel::Serializer
  attributes :id, :notification_id, :device_token, :country_code, :opened_at
end
