class RailsRoutesReloader
  def initialize(app)
    @app = app
  end

  def call(env)
    reload_routes_if_changed
    return *@app.call(env)
  end

  private

  def reload_routes_if_changed
    routes_reloader.execute_if_updated
  end

  def routes_reloader
    @routes_reloader ||= file_update_checker.new(rails_routes_files) { reload_routes }
  end

  def file_update_checker
    ActiveSupport::FileUpdateChecker
  end

  def rails_routes_files
    Pathname.new(Rails.root.join('config/routes/')).children
  end

  def reload_routes
    Rails.application.reload_routes!
  end
end
