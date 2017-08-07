# == Schema Information
#
# Table name: notifications
#
#  id                           :integer          not null, primary key
#  message                      :string(255)
#  message_id                   :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  filter                       :json
#  delivery_at                  :datetime
#  deep_link                    :string(255)
#  jid                          :string(255)
#  filter_count                 :integer
#  notification_trackings_count :integer          default(0)
#

class Notification < ActiveRecord::Base
  include Logcraft::Trackable

  has_many :notification_trackings
  validates :message, presence: true

  before_create :check_delivery_at, :count_filter
  after_create :delay_publish
  after_destroy :delete_schedule_queue

  def delay_publish
    if delivery_at.present? && (delivery_at > Time.zone.now)
      delay_sec = (delivery_at - Time.zone.now).to_i
    else
      delay_sec = 10.second
    end
    jid = NotificationPublisher.perform_in(delay_sec, id)
    update! jid: jid
  end

  def publish
    res = {}
    if filter.nil?
      res = AwsSns::PublishToTopic.new(message: message,
                                       deep_link: deep_link,
                                       notification_id: id).execute
    else
      if Device.ransack(filter).result.available.count > 0
        Device.ransack(filter).result.available.select(:id).find_each do |device|
          res[:message_id] = NotificationPushToDeviceWorker.perform_async(id, device.id)
        end
      end
    end
    create_activity(:publish, publish_message: build_aws_sns_message,
                              filter: filter,
                              deep_link: deep_link)
    update!(message_id: res[:message_id]) if res.present? && !res.is_a?(String)
  end

  def publish_to_device(device_id)
    device = Device.find(device_id)
    AwsSns::PublishToDevice.new(message: message,
                                device: device,
                                deep_link: deep_link,
                                notification_id: id).execute
  end

  def delete_schedule_queue
    if jid.present?
      schedule_queue = Sidekiq::ScheduledSet.new.find_job(jid)
      schedule_queue.delete if schedule_queue
    end
  end

  def check_delivery_at
    self.delivery_at = Time.zone.now if delivery_at.nil?
  end

  # device_type must is (ios, android, all)
  def build_aws_sns_message(device_type: 'all')
    option = { notification_id: id }
    option.merge!(deep_link: deep_link) if deep_link.present?
    AwsSnsMessage.new(message, device_type, option).build
  end

  def count_filter
    self.filter_count = Device.ransack(filter).result.available.count
  end

  def status
    res = message_id.present?
    I18n.t("notification.status.#{res}")
  end
end
