class UserNotificationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :message, :device_id

  validates_presence_of :message, :device_id
end