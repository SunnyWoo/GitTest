class Yonyou::Inventory
  attr_accessor :url, :request, :to_account

  def initialize
    @to_account = Settings.yonyou.to_account
    @request = Yonyou::Request.new
  end

  # @body ex:
  # {
  #   inventory: {
  #     code: work.product_code,
  #     name: work.name,
  #     sort_code: "1#{work.product.product_cmsc_code}",
  #     main_measure: '0102',
  #     entry: [
  #       {
  #         invcode: work.product_code
  #       }
  #     ]
  #   }
  # }
  #
  # @return ex
  # {
  #     "ping_after" => 3,
  #     "tradeid" => "5f4f1fb7f10411e5b65002004c4f4f50",
  #     "url" => "https://api.yonyouup.com:443/result?requestid=5f4f1fb7f10411e5b65002004c4f4f50"
  # }

  def add(body)
    request.post('https://api.yonyouup.com/api/inventory/add', add_query, body)
  end

  private

  def add_query
    {
      token: token,
      tradeid: trade_id,
      to_account: to_account
    }
  end

  def token
    @token ||= Yonyou::Token.new.token
  end

  def trade_id
    @trade_id ||= Yonyou::Trade.new.trade_id
  end
end
