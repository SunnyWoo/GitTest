set :stage, :production

set :access_key_id, ENV['AWS_ACCESS_KEY_ID']
set :secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']

set :stack_id, 'xxx'
set :app_id, 'xxx'

# Rollbar deploy tracking settings
set :rollbar_token, 'c69e71d301784244bf2a54e276cf4ed2'
set :rollbar_env, proc { fetch :stage }
set :rollbar_role, proc { :app }

# 製圖機
role :app, ENV['APP'] || %w(commandp@192.168.66.122 commandp@192.168.66.123)
set :deploy_to, '/Users/commandp/deploy/production'
set :branch,    'master'
set :user,      'commandp'
