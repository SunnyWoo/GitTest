require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'factory_girl'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'sidekiq/testing'
require 'database_cleaner'
require 'strip_attributes/matchers'
require 'webmock/rspec'

WebMock.disable_net_connect!(allow_localhost: true)

unless ENV['DRB']
  require 'simplecov'
  SimpleCov.start 'rails'
end

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# speeds up specs considerably
RSpec.configure do |config|
  config.tty = true

  config.before(:all) do
    $redis.client.reconnect
    # FactoryGirl.create :exchange_rate
  end

  config.after(:each) do
    if Rails.env.test?
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    end
    $redis.flushdb
  end

  config.before(:each) do
    $redis.flushdb
    Sidekiq::Worker.clear_all
    CurrencyType.create_default_data
  end

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, timeout: 120, js_errors: false)
  end
  Capybara.javascript_driver = :poltergeist

  config.before(:suite) do
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with(:deletion)
  end

  config.around(:each) do |ex|
    if ex.metadata[:type] == :feature
      DatabaseCleaner.cleaning { ex.run }
    else
      ex.run
    end
  end

  # http://stackoverflow.com/questions/5035982/optionally-testing-caching-in-rails-3-functional-tests
  config.around(:each) do |ex|
    caching = ActionController::Base.perform_caching
    ActionController::Base.perform_caching = ex.metadata[:caching]
    ex.run
    Rails.cache.clear
    ActionController::Base.perform_caching = caching
  end

  config.around(:each) do |ex|
    if ex.metadata.key?(:vcr)
      ex.run
    else
      VCR.turned_off { ex.run }
    end
  end

  config.around(:each) do |ex|
    if ex.metadata.key?(:freeze_time)
      Timecop.freeze { ex.run }
    else
      ex.run
    end
  end

  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
  config.filter_run_excluding :slow unless ENV['SLOW_SPECS']
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.infer_base_class_for_anonymous_controllers = true
  config.include HeaderVersionHelper
  config.include AuthRequestHelper
  config.include BodyMarcos
  config.include FeatureFlagHelper
  config.include FactoryGirl::Syntax::Methods
  config.include Devise::TestHelpers, type: :controller
  config.include Warden::Test::Helpers
  config.include HttpUserAgentHelper
  config.include OmniauthProvider
  config.include StubEnv::Helpers
  config.include StripAttributes::Matchers
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  Warden.test_mode!
end

RSpec::Matchers.define :exist_in_database do
  match do |actual|
    actual.class.exists?(actual.id)
  end
end

Rails.application.routes.default_url_options = {
  host: 'www.example.com',
  locale: :en
}
