require 'spec_helper'

describe IllustratorService::AlfheimImpositionArgumentsGenerator do
  Given(:definition) do
    {
      'labels' => [
        {
          'name' => 'OrderNumber',
          'contents' => [
            { 'locale' => 'zh-TW', 'content' => '%{order_number}' },
            { 'locale' => 'en', 'content' => '%{order_number}' }
          ]
        },
        {
          'name' => 'ProductName',
          'contents' => [
            { 'locale' => 'zh-TW', 'content' => '%{product_name}' },
            { 'locale' => 'en', 'content' => '%{product_name}' }
          ]
        }
      ]
    }
  end
  Given(:imposition){ Imposition::Alfheim.new(definition: definition) }
  Given(:works) { %w(w1 w2 w3) }
  Given(:items) do
    3.times.to_a.map do |i|
      double(PrintItem).tap do |item|
        allow(item).to receive(:id).and_return(i.succ)
        allow(item).to receive(:timestamp_no).and_return("timestamp_no_#{i.succ}")
        allow(item).to receive_message_chain('order_item.itemable').and_return(works[i])
      end
    end
  end

  Given(:arg1) { OpenStruct.new(generate: { image: 'image1', layers: ['image1_layer'] }) }
  Given(:arg2) { OpenStruct.new(generate: { image: 'image2', layers: ['image2_layer'] }) }
  Given(:arg3) { OpenStruct.new(generate: { image: 'image3', layers: ['image3_layer'] }) }

  Given {
    allow(imposition).to receive(:download_template).and_return('some/template/path/file.ai')
    allow(generator).to receive(:content_arguments).and_return(order_number: 'ORDER_NO', product_name: 'PRODUCT_NAME')
    allow(IllustratorService::WorkArgumentsGenerator).to receive(:new).with('w1').and_return(arg1)
    allow(IllustratorService::WorkArgumentsGenerator).to receive(:new).with('w2').and_return(arg2)
    allow(IllustratorService::WorkArgumentsGenerator).to receive(:new).with('w3').and_return(arg3)
  }

  describe '#generate' do
    Given(:generator) { IllustratorService::AlfheimImpositionArgumentsGenerator.new(imposition, items) }
    Given(:item1) { arguments[:items][0] }
    Given(:item2) { arguments[:items][1] }
    When(:arguments) { generator.generate }
    Then { expect(arguments).to be_kind_of(Hash) }
    And { expect(arguments[:items].size).to eq 3 }
    And { expect(arguments[:template]).to eq Rails.root.join('some/template/path/file.ai').to_s }
    And { expect(arguments[:output]).to eq Rails.root.join('tmp/1_2_3.pdf').to_s }
    And do
      expect(item1).to eq(
        image: 'image1',
        layers: ['image1_layer'],
        qrcode: Rails.root.join('tmp/qrcode-timestamp_no_1.svg').to_s,
        labels: [{ name: "OrderNumber", content: "ORDER_NO" }, { name: "ProductName", content: "PRODUCT_NAME" }]
      )
    end
    And do
      expect(item2).to eq(
        image: 'image2',
        layers: ['image2_layer'],
        qrcode: Rails.root.join('tmp/qrcode-timestamp_no_2.svg').to_s,
        labels: [{ name: "OrderNumber", content: "ORDER_NO" }, { name: "ProductName", content: "PRODUCT_NAME" }]
      )
    end
  end
end
