require 'spec_helper'

RSpec.describe YtoExpress::Response do
  Given(:response) { YtoExpress::Response.new("<Response></Response>") }

  context '#body' do
    context 'when valid response' do
      Given(:valid_hash_response) do
        {
          'logisticProviderID' => 'YTO',
          'txLogisticID' => 'P1605187300011CN',
          'clientID' => 'K10101010',
          'mailNo' => '858591141255',
          'distributeInfo' => {
            'shortAddress' => '140-031-000',
            'consigneeBranchCode' => '220034',
            'packageCenterCode' => '220902',
            'packageCenterName' => '天津转运中心'
          },
          'code' => '200',
          'success' => 'true'
        }
      end
      Given(:success_body) do
        {
          logistic_provider_id: 'YTO',
          tx_logistic_id: 'P1605187300011CN',
          client_id: 'K10101010',
          mail_no: '858591141255',
          short_address: '140-031-000',
          consignee_branch_code: '220034',
          package_center_code: '220902',
          package_center_name: '天津转运中心',
          code: '200',
          success: true
        }
      end
      before do
        allow(response).to receive(:response).and_return(valid_hash_response)
      end

      Then { response.body == success_body }
    end

    context 'when invalid response' do
      Given(:invalid_hash_response) do
        {
          'txLogisticID' => nil,
          'logisticProviderID' => 'YTO',
          'code' => 'S01',
          'success' => 'false',
          'reason' => '订单报文不合法'
        }
      end
      Given(:failed_body) do
        {
          tx_logistic_id: nil,
          logistic_provider_id: 'YTO',
          code: 'S01',
          success: false,
          error_type: '订单报文不合法',
          reason: '订单报文不合法',
          repeat_order: false
        }
      end
      before do
        allow(response).to receive(:response).and_return(invalid_hash_response)
      end
      Then { response.body == failed_body }
    end
  end
end
