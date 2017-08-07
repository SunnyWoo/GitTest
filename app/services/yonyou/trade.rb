class Yonyou::Trade
  attr_accessor :url, :request

  def initialize
    @url = 'https://api.yonyouup.com/system/tradeid'
    @request = Yonyou::Request.new
  end

  def trade_id
    get.trade.id
  end

  private

  def token
    @token ||= Yonyou::Token.new.token
  end

  def get
    request.get(url, token: token)
  end
end
