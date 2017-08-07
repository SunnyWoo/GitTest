class PrecompileRequired < StandardError; end

Chef::Log.info('Running deploy/before_migrate.rb...')

%w(
  webpack
  assets
  print_works).each do |d|
  Chef::Log.info("Symlinking #{release_path}/public/#{d} to #{new_resource.deploy_to}/shared/#{d}")

  link "#{release_path}/public/#{d}" do
    to "#{new_resource.deploy_to}/shared/#{d}"
  end
end

%w(application.yml
   sidekiq.yml
   paypal.yml
   oneapm.yml
   newrelic.yml
   shards.yml).each do |f|
  Chef::Log.info("Symlinking #{release_path}/config/#{f} to #{new_resource.deploy_to}/shared/config/#{f}")

  link "#{release_path}/config/#{f}" do
    to "#{new_resource.deploy_to}/shared/config/#{f}"
    only_if { ::File.exist?("#{new_resource.deploy_to}/shared/config/#{f}") }
  end
end

region = new_resource.environment['REGION']
rails_env = new_resource.environment['RAILS_ENV']
Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")

execute "REGION=#{region} RAILS_ENV=#{rails_env} rake assets:precompile" do
  begin
    releases_path = Pathname.new "#{new_resource.deploy_to}/releases"
    latest_release = `ls -xr #{releases_path}`.split[1]
    # precompile if this is the first deploy
    fail PrecompileRequired unless latest_release
    latest_release_path = releases_path.join(latest_release)

    assets_dependencies = %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb)
    assets_dependencies.each do |dep|
      release = Pathname.new(release_path).join(dep)
      latest = latest_release_path.join(dep)
      # skip if both directories/files do not exist
      next if [release, latest].map { |d| ::File.exist?(d) }.include?(false)
      # execute raises if there is a diff
      result = `diff -Nqr #{release} #{latest}`
      fail PrecompileRequired if result.to_s != ''
    end
    Chef::Log.info('Skipping asset precompile, no asset diff found')
    command ''
    action :nothing
  rescue PrecompileRequired
    cwd release_path
    command "su deploy -c 'bundle exec rake assets:precompile'"
    action :run
    environment(
      'RAILS_ENV' => rails_env,
      'REGION' => region
    )
  end
end
npm_registry_endpoint = region == 'china' ? 'https://registry.npm.taobao.org' : 'http://registry.npmjs.org/'

Chef::Log.info("Symlinking #{release_path}/node_modules/# to #{new_resource.deploy_to}/shared/node_modules")
link "#{release_path}/node_modules" do
  to "#{new_resource.deploy_to}/shared/node_modules"
end
Chef::Log.info("Create #{new_resource.deploy_to}/shared/node_modules")
directory "#{new_resource.deploy_to}/shared/node_modules" do
  owner  'deploy'
  group  'www-data'
  mode   '0755'
  not_if { ::File.exist?("#{new_resource.deploy_to}/shared/node_modules") }
end

Chef::Log.info("Create #{new_resource.deploy_to}/shared/webpack")
directory "#{new_resource.deploy_to}/shared/webpack" do
  owner  'deploy'
  group  'www-data'
  mode   '0755'
  not_if { ::File.exist?("#{new_resource.deploy_to}/shared/webpack") }
end

Chef::Log.info("Symlinking #{release_path}/node_modules/# to #{new_resource.deploy_to}/shared/node_modules")
link "#{release_path}/node_modules" do
  owner  'deploy'
  group  'www-data'
  to "#{new_resource.deploy_to}/shared/node_modules"
end

Chef::Log.info("Symlinking #{release_path}/public/webpack to #{new_resource.deploy_to}/shared/webpack")
link "#{release_path}/public/webpack" do
  owner  'deploy'
  group  'www-data'
  to     "#{new_resource.deploy_to}/shared/webpack"
end

Chef::Log.info('Installing Node.js modules')
execute "npm install -registry=#{npm_registry_endpoint} --production" do
  cwd release_path
  command "su deploy -c 'npm install -registry=#{npm_registry_endpoint} --production'"
end

Chef::Log.info('Compile webpack entries')
execute "REGION=#{region} RAILS_ENV=#{rails_env} rake webpack:compile" do
  cwd release_path
  command 'su deploy -c "bundle exec rake webpack:compile"'
  environment('RAILS_ENV' => rails_env, 'REGION' => region)
end

Chef::Log.info("Set ENV for #{rails_env}...")

ENV['LANG'] = 'zh_TW.UTF-8'
ENV['LANGUAGE'] = 'zh_TW:zh'
