#############################
# /config/deploy/staging.rb #
#############################
set :stage, :staging

set :access_key_id, ENV['AWS_ACCESS_KEY_ID']
set :secret_access_key, ENV['AWS_SECRET_ACCESS_KEY']

set :stack_id, '51ec10f7-f506-42c6-be08-ed665315395e'
set :app_id, 'bcefcfa7-558f-4aa0-81e3-97a58803115c'
set :deploy_comment, "#{(`git rev-parse HEAD`).gsub(/\n/, '')[0..9]} By #{(`git log -1 --format='%an'`).gsub(/\n/, '')}"
# set :deploy_comment, "#{(`git rev-parse HEAD`).gsub(/\n/,'')[0..9]}:#{(`git log -1 --pretty=%B`).gsub(/\n/,'').gsub(/\[/,'(').gsub(/\]/,')')}By#{(`git log -1 --format='%an'`).gsub(/\n/,'')}"
# json_file = 'config/deploy/opworks_custom_json/staging.json'
# opsworks_custom_json = File.read(json_file)
# set :opsworks_custom_json, opsworks_custom_json

# Rollbar deploy tracking settings
set :rollbar_token, 'c69e71d301784244bf2a54e276cf4ed2'
set :rollbar_env, proc { fetch :stage }
set :rollbar_role, proc { :app }
