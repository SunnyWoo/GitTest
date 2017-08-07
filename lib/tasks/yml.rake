namespace :yml do
  require 'csvify'
  include Csvify
  desc "convert config/locales/*.yml to csv file"
  task convert_to_csv: :environment do
    Dir.chdir('config/locales') do
      Dir.glob(File.join("**","*.yml")).each do |file|
        yml_data = YAML.load_file(file)
        data = {}
        visit(data, yml_data)
        export_to_csv(file, data)
      end
    end
  end
end
