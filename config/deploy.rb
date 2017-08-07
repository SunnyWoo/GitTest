set :application, 'commandp'

# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

# set :deploy_to, '/var/www/my_app'
# set :scm, :git
set :repo_url, 'git@github.com:commandp/commandp-service.git'

# set :format, :pretty
# set :log_level, :debug
# set :pty, true

set :linked_files, %w{config/database.yml config/application.yml config/paypal.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
# set :keep_releases, 5

set :ssh_options, { forward_agent: true }
set :sidekiq_queue, %w(print_images create_archive_item google)
set :sidekiq_concurrency, 5
set :default_env, { path: '/usr/local/bin:$PATH' }
set :pty, true

namespace :deploy do

  before :starting, :check_sidekiq_hooks do
    on roles(:app) do
      execute "cd #{current_path} && if [[ -f #{shared_path}/tmp/pids/adobe.pid ]]; then ~/.rvm/bin/rvm default do bundle exec sidekiqctl stop #{shared_path}/tmp/pids/adobe.pid 10; fi"
    end
  end

  after :publishing, :restart_sidekiq do
    on roles(:app) do
      execute "cd #{current_path} && ( PATH=/usr/local/bin:$PATH REGION=#{fetch(:REGION)} ~/.rvm/bin/rvm default do bundle exec sidekiq --index 0 \
                                                                                                               --pidfile #{shared_path}/tmp/pids/adobe.pid \
                                                                                                               --environment #{fetch(:stage)} \
                                                                                                               --logfile #{shared_path}/log/sidekiq_adobe.log \
                                                                                                               --queue adobe \
                                                                                                               --concurrency 1 \
                                                                                                               --daemon)"
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      # execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  after :finishing, 'deploy:cleanup'

end

# TODO: 應該要存到跟 linked_file 一樣的路徑, 目前都塞 config/deployed/staging :(
namespace :config do
  task :download do
    require 'fileutils'

    on roles(:app), in: :sequence, wait: 5 do
      fetch(:linked_files).each do |file|
        FileUtils.mkdir_p("config/deployed/#{fetch(:stage)}")
        download! "#{release_path}/#{file}", "config/deployed/#{fetch(:stage)}"
      end
    end
  end

  task :upload do
    on roles(:app), in: :sequence, wait: 5 do
      fetch(:linked_files).each do |file|
        upload! "config/deployed/#{fetch(:stage)}/#{File.basename(file)}", "#{shared_path}/config"
      end
    end
  end
end
