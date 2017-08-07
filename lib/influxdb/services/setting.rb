module Influxdb::Services
  class Setting
    RETRY_COUNT = 3

    attr_reader :client

    # Influxdb::Services::Setting.new(({:host => '127.0.0.1', :db_name => 'mydb'}))
    def initialize(opts = {})
      influxdb_host = opts.fetch(:host, '127.0.0.1')
      influxdb_port = opts.fetch(:port, 8086)
      influxdb_db_name = opts.fetch(:db_name, nil)
      influxdb_username = opts.fetch(:username, nil)
      influxdb_password = opts.fetch(:password, nil)

      @client = ::InfluxDB::Client.new(influxdb_db_name,
                                       port:           influxdb_port,
                                       host:           influxdb_host,
                                       username:       influxdb_username,
                                       password:       influxdb_password,
                                       retry:          RETRY_COUNT,
                                       time_precision: 'n')
    end

    def push(measurement, tags = {}, values = {}, time = nil)
      time ||= Time.now.utc
      timestamp = (time.to_f * 1_000_000_000).to_i

      @client.write_point(measurement, { tags:      tags,
                                         values:    values,
                                         timestamp: timestamp }, 'n')
    end

    def list_databases
      @client.list_databases
    end

    def create_database(database)
      @client.create_database(database)
    end

    def delete_database(database)
      @client.delete_database(database)
    end
  end
end
