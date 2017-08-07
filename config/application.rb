require File.expand_path('../boot', __FILE__)
ENV['RANSACK_FORM_BUILDER'] = '::SimpleForm::FormBuilder'

# Pick the frameworks you want:
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
# require 'rails/test_unit/railtie'
require 'rails_autolink'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
if ENV['REGION'] == 'china'
  Bundler.require(:default, Rails.env)
else
  Bundler.require(:default, :global, Rails.env)
end

module CommandP
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Taipei'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    config.i18n.available_locales = %w(zh-TW zh-CN zh-HK en ja)
    config.i18n.default_locale = :en
    config.i18n.fallbacks = %w(en)
    config.i18n.enforce_available_locales = true

    config.active_record.raise_in_transactional_callbacks = true

    config.assets.precompile += %w( admin.css admin.js admin_v2.css admin_v2.js
                                    admin_v3.css admin_v3.js
                                    home.css theme.css admin/admin-bootstrap.css
                                    print.css order.css print.js order_mail.css
                                    beta/beta_conflict.css beta/beta.css
                                    beta.css editor.css editor.js phone.css
                                    phone.js pdf.css app.js app.css mobile.css
                                    mobile.js designer_template_editor.js designer_template_editor.css
                                    designer_store.css designer_store.js flexible.js store_landing_page.js store_landing_page.css
                                    daily_report/order_sticker.js rewards.css rewards.js)
    config.assets.precompile += %w(*.png *.jpg *.jpeg *.gif *.svg *.ttf *.otf)
    config.assets.paths << '#{Rails.root}/app/assets/fonts'

    # factory gilr
    config.generators do |g|
      g.test_framework :rspec, fixture: true, views: false, fixture_replacement: :factory_girl
      g.fixture_replacement :factory_girl, dir: 'spec/factories'
    end

    config.compass.require 'ninesixty'

    config.middleware.use Rack::Deflater

    config.autoload_paths << Rails.root.join('lib')
    config.autoload_paths << Rails.root.join('app/wrappers')
    config.autoload_paths << Rails.root.join('app/serializers/concerns')
    config.autoload_paths << Rails.root.join('app/serializers/decorators')

    require 'request_summary_logging/log_middleware'
    config.middleware.use RequestSummaryLogging::LogMiddleware

    require 'rails_routes_reloader'
    config.middleware.use RailsRoutesReloader

    config.react.addons = true

    config.middleware.delete(ActionDispatch::Cookies)
    config.middleware.delete(ActionDispatch::Session::CookieStore)
    config.middleware.insert_before(Rails::Rack::Logger, ActionDispatch::Session::CookieStore)
    config.middleware.insert_before(ActionDispatch::Session::CookieStore, ActionDispatch::Cookies)
    config.log_tags = [->(req) { "request_id:#{req.uuid}" },
                       ->(req) { "session_id:#{req.session[:session_id]}" },
                       ->(req) { "user_agent:#{req.user_agent}" }]

    config.middleware.insert_before 0, 'Rack::Cors' do
      allow do
        origins '*'
        resource '/api/*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
        resource '/oauth/*', headers: :any, methods: [:get, :post]
        resource '/assets/*', headers: :any, methods: [:get]
        resource '/uploads/*', headers: :any, methods: [:get]
        resource '/rewards/*', headers: :any, methods: [:patch]
      end
    end
  end
end

require 'hashie_mash_serializers'
require 'region'
