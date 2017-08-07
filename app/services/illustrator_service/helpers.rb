require 'open-uri'

module IllustratorService::Helpers
  def save_to_tempfile(url)
    uri = URI.parse(url)
    tempfile = Rails.root.join('tmp', "#{Time.now.to_i}_#{File.basename(uri.path)}")
    file = open(tempfile, 'wb')
    file.write open(url).read
    file
  end
end
