require 'net/http'
require 'open-uri'

class LanguageDetector

  QUERY_URL = "https://www.googleapis.com/language/translate/v2/detect?key=#{Settings.google_translate_api_key}&q="

  class << self

    def what_lang(text)
      response = Net::HTTP.get_response(URI.parse(QUERY_URL + CGI.escape(text)))
      JSON.parse(response.body)['data']['detections'][0][0]['language']
    end

  end

end
