# == Schema Information
#
# Table name: logcraft_activities
#
#  id             :integer          not null, primary key
#  key            :string(255)
#  trackable_id   :integer
#  trackable_type :string(255)
#  user_id        :integer
#  user_type      :string(255)
#  source         :json
#  message        :text
#  extra_info     :json
#  created_at     :datetime
#  updated_at     :datetime
#

class Logcraft::Activity < ActiveRecord::Base
  after_commit :push_influxdb, on: [:create, :update], if: :enable_influxdb?
  self.table_name = :logcraft_activities

  serialize :source, Hashie::Mash.pg_json_serializer
  serialize :extra_info, Hashie::Mash.pg_json_serializer

  belongs_to :trackable, -> { try(:with_deleted) || all }, polymorphic: true
  belongs_to :user, polymorphic: true

  scope :ordered, -> { order('created_at DESC') }
  scope :from_old_to_new, -> { order('created_at ASC') }
  scope :latest_first, -> { unscoped.order('created_at DESC') }
  scope :print, -> { where('trackable_type = ? OR trackable_type = ? ', 'Factory', 'FtpService').ordered }
  scope :invoice, -> { where('trackable_type = ?', 'InvoiceService') }

  scope :channel, ->(channel) { where("source ->> 'channel' = ?", channel) }

  private

  def push_influxdb
    PushActivityToInfluxdbWorker.perform_async('activity', { region: Region.region,
                                                             trackable_type: trackable_type }, id)
  end

  protected

  def enable_influxdb?
    (Settings['InfluxDB'] && Settings['InfluxDB']['host']).present?
  end
end
