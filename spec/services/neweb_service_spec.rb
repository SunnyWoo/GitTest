describe NewebService do
  let(:neweb) { NewebService.new }

  describe '#hostname' do
    it 'has default value' do
      expect(neweb.hostname).to eq(NewebService::DEFAULT_OPTIONS[:hostname])
    end

    it 'returns given value' do
      neweb = NewebService.new(hostname: 'neweb.dev')
      expect(neweb.hostname).to eq('neweb.dev')
    end
  end

  describe '#payment_url' do
    it 'returns correct payment url' do
      expect(neweb.payment_url).to eq("http://#{neweb.hostname}/CashSystemFrontEnd/Payment")
    end
  end

  describe '#payment_params' do
    it 'checks required fields' do
      expect { neweb.payment_params }.to raise_error(/Missing required fields/)
    end

    it 'returns correct params' do
      params = neweb.payment_params(ordernumber: 'order01',
                                    amount: 1337,
                                    paymenttype: 'ATM',
                                    paytitle: 'title',
                                    paymemo: 'memo')
      expect(params[:bankid]).to eq('007')
      expect(params[:hash]).to eq(neweb.md5(neweb.merchantnumber, neweb.code, 1337, 'order01'))
    end
  end

  describe '#query_url' do
    it 'returns correct query url' do
      expect(neweb.query_url).to eq("http://#{neweb.hostname}/CashSystemFrontEnd/Query")
    end
  end

  describe '#valid_write_off_response?' do
    it 'validates response string' do
      response = neweb.append_write_off_hash("merchantnumber=#{neweb.merchantnumber}&ordernumber=90630002&serialnumber=32&writeoffnumber=09063071000001&timepaid=20090630180121&paymenttype=ATM&amount=502&tel=")
      expect(neweb.valid_write_off_response?(response)).to be(true)
    end
  end

  describe '#valid_write_off_params?' do
    it 'validates params' do
      params = {
        'merchantnumber' => '459807',
        'ordernumber' => '90630002',
        'serialnumber' => '32',
        'writeoffnumber' => '09063071000001',
        'timepaid' => '20090630180121',
        'paymenttype' => 'ATM',
        'amount' => '502',
        'tel' => '',
        'hash' => 'c220b67365f9e9e26bb042b284be9c53'
      }
      expect(neweb.valid_write_off_params?(params)).to be(true)
    end
  end

  describe '#cancel_order_url' do
    it 'returns correct cancel order url' do
      expect(neweb.cancel_order_url).to eq("http://#{neweb.hostname}/CashSystemFrontEnd/CancelOrderServlet")
    end
  end
end
