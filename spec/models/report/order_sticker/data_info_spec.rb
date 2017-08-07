require 'spec_helper'

describe Report::OrderSticker::DataInfo do
  context '.extract_from_order_items' do
    before do
      layer_1 = create :layer, layer_type: 'frame', material_name: 'cp_frames_01'
      layer_2 = create :layer, layer_type: 'line', material_name: 'cp_lines_01'
      layer_3 = create :layer, layer_type: 'sticker', material_name: 'cp_stickers_01'
      @work = create :work, product: create(:mug_product_model), layers: [layer_1, layer_2, layer_3]
      @work2 = create :work, product: create(:mug_product_model), layers: [layer_1, layer_2]
      @work3 = create :work, product: create(:mug_product_model), layers: [layer_1]
      @standardized_work = create :standardized_work
    end

    Given!(:order_items) do
      [
        (create :order_item, itemable: @work),
        (create :order_item, itemable: @work2),
        (create :order_item, itemable: @work3, quantity: 3),
        (create :order_item, itemable: @standardized_work)
      ]
    end

    Given(:answer) do
      {
        'frame' => {
          'mug' => 5
        },
        'line' => {
          'mug' => 2
        },
        'sticker' => {
          'mug' => 1
        }
      }
    end
    When(:result) { Report::OrderSticker::DataInfo.extract_from_order_items(order_items) }
    Then { result == answer }
  end

  context 'for transposion' do
    Given(:default_data) {
      {
        'frame' => {
          'mug' => 0,
          'iphone' => 0,
          'ipad' => 0
        },
        'line' => {
          'mug' => 0,
          'iphone' => 0,
          'ipad' => 0
        },
        'sticker' => {
          'mug' => 0,
          'iphone' => 0,
          'ipad' => 0
        }
      }
    }

    Given(:data) do
      {
        'frame' => {
          'mug' => 2,
          'iphone' => 4,
          'ipad' => 6
        },
        'line' => {
          'mug' => 2,
          'iphone' => 4,
          'ipad' => 6
        },
        'sticker' => {
          'mug' => 2,
          'iphone' => 4,
          'ipad' => 6
        }
      }
    end

    Given(:transposed_data) do
      {
        'mug' => {
          'frame' => 2,
          'line' => 2,
          'sticker' => 2
        },
        'iphone' => {
          'frame' => 4,
          'line' => 4,
          'sticker' => 4
        },
        'ipad' => {
          'frame' => 6,
          'line' => 6,
          'sticker' => 6
        }
      }
    end

    context '#transpose_to_hash' do
      Given(:data_info) { Report::OrderSticker::DataInfo.new(data) }
      When(:result) do
        allow_any_instance_of(Report::OrderSticker::DataInfo).to receive(:default_data).and_return(default_data)
        data_info.send(:transpose_to_hash)
      end
      Then { result == transposed_data }
    end

    context '#convert_hash_to_rows' do
      Given(:data_info) { Report::OrderSticker::DataInfo.new({}) }
      When(:result) { data_info.send(:convert_hash_to_rows, data) }
      Then { result.all? { |item| item.is_a? RowNumber } }
      And { result.map(&:key) == data.keys }
      And { result.map(&:hash) == data.values }
    end
  end
end
