Lograge.module_eval do
  ActiveSupport::LogSubscriber.log_subscribers.each do |subscriber|
    case subscriber
    when ActiveRecord::LogSubscriber
      unsubscribe(:active_record, subscriber) unless Rails.env.development?
    end
  end
end

module SQLLog
  class LogSubscriber < ActiveSupport::LogSubscriber
    IGNORE_PAYLOAD_NAMES = %w(SCHEMA EXPLAIN)

    def self.runtime=(value)
      ActiveRecord::RuntimeRegistry.sql_runtime = value
    end

    def self.runtime
      ActiveRecord::RuntimeRegistry.sql_runtime ||= 0
    end

    def self.reset_runtime
      rt, self.runtime = runtime, 0
      rt
    end

    def initialize
      super
    end

    def render_bind(column, value)
      if column
        if column.binary?
          # This specifically deals with the PG adapter that casts bytea columns into a Hash.
          value = value[:value] if value.is_a?(Hash)
          value = value ? "<#{value.bytesize} bytes of binary data>" : '<NULL binary data>'
        end

        [column.name, value]
      else
        [nil, value]
      end
    end

    def sql(event)
      self.class.runtime += event.duration
      return unless logger.debug?

      payload = event.payload

      return if IGNORE_PAYLOAD_NAMES.include?(payload[:name])

      unless (payload[:binds] || []).empty?
        binds = '  ' + payload[:binds].map { |col, v|
          render_bind(col, v)
        }.inspect
      end
      ids = Thread.current[:log_uuid_session_id] || Array.new(2)
      log = {
        name: payload[:name],
        duration: event.duration.round(1),
        binds: binds,
        message: payload[:sql],
        type: 'rails-sql',
        environment: Rails.env,
        request_id: ids[0],
        session_id: ids[1]
      }.to_json

      debug log
    end

    def logger
      ActiveRecord::Base.logger
    end
  end
end

SQLLog::LogSubscriber.attach_to :active_record unless Rails.env.development?
