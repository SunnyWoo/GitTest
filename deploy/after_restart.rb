rails_env = new_resource.environment['RAILS_ENV']
region = new_resource.environment['REGION']

Chef::Log.info("Create seed data for RAILS_ENV=#{rails_env}...")

execute 'whenever' do
  cwd release_path
  command "bundle exec whenever --update-crontab commandp --set 'environment=#{rails_env}'"
  environment(
    'RAILS_ENV' => rails_env,
    'REGION' => region
  )
  only_if { node['hostname'] =~ /api-01/ }
end

execute 'sitemap_generator' do
  cwd release_path
  command 'bundle exec rake sitemap:refresh:no_ping -s'
  environment(
    'RAILS_ENV' => rails_env,
    'REGION' => region
  )
end
