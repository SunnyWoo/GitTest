#############################
# /config/deploy/production_china.rb #
#
# $ cap production_china deploy
#############################
set :stage, :production

set :REGION, 'china'

fetch(:default_env).merge!(REGION: 'china')

# 製圖機
set :deploy_to, '/Users/commandp/deploy/production'
set :branch,    'master'
set :user,      'commandp'

# Rollbar deploy tracking settings
set :rollbar_token, "75f7d0c4533044ffac8ef8d86107ca65"
set :rollbar_env, proc { fetch :stage }
set :rollbar_role, proc { :app }

role :app, %w(commandp@192.168.77.122 commandp@192.168.77.123)
