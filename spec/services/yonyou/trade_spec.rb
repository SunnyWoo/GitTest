require 'spec_helper'

describe Yonyou::Trade do
  Given(:trade) { Yonyou::Trade.new }

  context '#trade_id' do
    Given(:response) do
      {
        "errcode" => 0,
        "errmsg" => "成功",
        "trade" => {
          "id" => "f4de1cc3f17311e5b65002004c4f4f50"
        }
      }
    end
    Given(:hashie_res) { Hashie::Mash.new response }
    before { allow(trade).to receive(:get).and_return(hashie_res) }
    Then { trade.trade_id == 'f4de1cc3f17311e5b65002004c4f4f50' }
  end
end
