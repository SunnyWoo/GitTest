require 'convert_helper'
module RequestSummaryLogging
  class LogSubscriber < ActiveSupport::LogSubscriber
    include ConvertHelper

    def logger
      @logger ||= create_logger
    end

    def create_logger
      logger = ActiveSupport::Logger.new(Rails.root + 'log/request_summary.log')
      logger.formatter = Formatter.new
      logger
    end

    class Formatter
      def call(severity, time, _progname, msg)
        log = {
          level:     severity,
          timestamp: time.utc.strftime('%FT%T.%6NZ')
        }
        "#{log.merge!(msg).to_json}\n"
      end
    end

    def redirect_to(event)
      Thread.current[:logged_location] = event.payload[:location]
    end

    INTERNAL_PARAMS = %w(controller action format _method only_path)

    def process_action(event)
      payload = event.payload
      param_method = payload[:params]['_method']
      params = payload[:params].except(*INTERNAL_PARAMS)

      Thread.current[:logged_location] = nil
      Thread.current[:payload] = payload
      message = {
        request_id:     payload[:request_id],
        session_id:     payload[:session_id],
        method:         param_method ? param_method.upcase : payload[:method],
        status:         compute_status(payload),
        ip:             Thread.current[:logged_ip],
        path:           payload[:path],
        redirect_to:    Thread.current[:logged_location],
        request_params: convert_params(params),
        user_agent:     payload[:user_agent]
      }
      logger.info message
    end

    def compute_status(payload)
      status = payload[:status]
      if status.nil? && payload[:exception].present?
        exception_class_name = payload[:exception].first
        status = ActionDispatch::ExceptionWrapper.status_code_for_exception(exception_class_name)
      end
      status
    end
  end
end

RequestSummaryLogging::LogSubscriber.attach_to :action_controller
