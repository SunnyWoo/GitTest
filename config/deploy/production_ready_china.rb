set :stage, :production_ready

set :access_key_id, ENV['AWS_ACCESS_KEY_ID']
set :secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']

set :stack_id, 'xxx'
set :app_id, 'xxx'

set :REGION, 'china'

fetch(:default_env).merge!(REGION: 'china')

# Rollbar deploy tracking settings
set :rollbar_token, 'c69e71d301784244bf2a54e276cf4ed2'
set :rollbar_env, proc { fetch :stage }
set :rollbar_role, proc { :app }

# 製圖機
role :app, %w(commandp@192.168.77.122 commandp@192.168.77.123)
set :deploy_to, '/Users/commandp/deploy/production_ready'
set :branch,    ENV['BRANCH'] || "#{(`git branch -a | grep 'origin/release' | sort -r | head -n 1 | sed -e 's|remotes\/origin\/||g'`).gsub(/\n/,'').strip}"
set :user,      'commandp'
