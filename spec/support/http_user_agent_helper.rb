module HttpUserAgentHelper

  def user_agent
    { 'HTTP_USER_AGENT' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/37.0.2062.124 Safari/537.36' }
  end

  def accept_lang(locale = 'en')
    { 'Accept-Language' => locale }
  end

end
