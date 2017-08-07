class PushActivityToInfluxdbWorker
  include Sidekiq::Worker

  # PushActivityToInfluxdbWorker.perform_async('logx', { region: 'taiwan go go go ' }, 1)

  def perform(series, tags, activity_id)
    sleep 1
    activity = Logcraft::Activity.find(activity_id)
    influxdb = Influxdb::Services::Setting.new(host:     Settings.InfluxDB.host,
                                               port:     Settings.InfluxDB.port,
                                               db_name:  Settings.InfluxDB.db_name,
                                               username: Settings.InfluxDB.username,
                                               password: Settings.InfluxDB.password)
    factory = Influxdb::Services::Factory.new(activity.as_json)
    influxdb.push(series, tags, factory.value, factory.timestamp)
  end
end
