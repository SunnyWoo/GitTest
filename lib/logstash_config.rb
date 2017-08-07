module LogstashConfig
  LogStashLogger.configure do |config|
    config.max_message_size = ENV['LOGSTASH_MAX_MESSAGE_SIZE'] || 2000
  end

  def logstash_enable?
    ENV['LOGSTASH_ENABLE'].to_b
  end

  def setup_logstash(config)
    config.log_level = :debug
    config.lograge.enabled = true

    config.logstash.type = logstash_type
    config.logstash.host = logstash_host
    config.logstash.port = logstash_port
    config.logstash.list = logstash_list
    config.lograge.formatter = Lograge::Formatters::Logstash.new
    config.logstash.formatter = :json_lines
    config.colorize_logging = false
    config.logstash.buffer_max_items = 50
    config.logstash.buffer_max_interval = 5
    config.lograge.custom_options = lambda do |event|
      {
        request_id:     event.payload[:request_id],
        session_id:     event.payload[:session_id],
        remote_ip:      event.payload[:ip],
        type:           'rails_request',
        environment:    event.payload[:environment],
        region:         event.payload[:region],
        user:           event.payload[:user],
        admin:          event.payload[:admin],
        site:           event.payload[:site],
        access_token:   event.payload[:access_token],
        user_agent:     event.payload[:user_agent],
        request_params: event.payload[:request_params]
      }
    end
  end

  private

  def logstash_type
    (ENV['LOGSTASH_TYPE'] || :file).to_sym
  end

  def logstash_port
    ENV['LOGSTASH_PORT']
  end

  def logstash_host
    ENV['LOGSTASH_HOST'] || 'localhost'
  end

  def logstash_list
    ENV['LOGSTASH_LIST'] || 'logstash'
  end
end
