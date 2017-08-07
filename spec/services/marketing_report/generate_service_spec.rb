require 'spec_helper'

describe MarketingReport::GenerateService do
  context '#initialize' do
    Given(:args) do
      { type: type }
    end
    context 'with valid marketing report type' do
      Given(:type) { MarketingReport::GenerateService::ADAPTAERS.sample }
      Then { expect { MarketingReport::GenerateService.new(args) }.not_to raise_error }
    end

    context 'with invalid marketing report type' do
      Given(:type) { 'WTF' }
      Then { expect { MarketingReport::GenerateService.new(args) }.to raise_error(InvalidMarketingReportTypeError) }
    end
  end

  context '#execute' do
    Given(:args) do
      {
        type:      'order_items_sell_list',
        starts_at: '2016-01-01',
        ends_at:   '2016-07-01'
      }
    end
    Given(:generate_service) { MarketingReport::GenerateService.new(args) }
    context 'returns successful result object with payload when it successes' do
      Given(:csv) do
        CSV.generate do |csv|
          csv << %w(1 2 3 4)
          csv << %w(a b c d)
        end
      end
      Given { allow(generate_service).to receive_message_chain('report_generator.send_data').and_return(csv) }
      When(:result) { generate_service.execute }
      Then { result.success? }
      And { result.payload.is_a? Tempfile }
      And { result.payload.read == csv }
    end

    context 'returns failed result object with error when it fails' do
      Given { allow(generate_service).to receive(:process).and_raise(ServiceObjectError, 'Over my dead money') }
      When(:result) { generate_service.execute }
      Then { !result.success? }
      And { result.error.message == 'Over my dead money' }
    end
  end
end
