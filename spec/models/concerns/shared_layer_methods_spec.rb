require 'spec_helper'

Temping.create :dummy_layer_class do
  with_columns do |t|
    t.string :image
    t.string :filtered_image
    t.string :layer_type
  end
  include SharedLayerMethods
end

describe SharedLayerMethods do
  describe '#printable?' do
    context 'layer_type=photo' do
      Given(:layer_type){ 'photo' }
      context 'with image and filtered_image' do
        Given(:layer) { DummyLayerClass.create(image: 'foo', filtered_image: 'bar', layer_type: layer_type) }
        Then { expect(layer.printable?).to eq true }
      end

      context 'without filtered_image' do
        Given(:layer) { DummyLayerClass.create(image: 'foo', filtered_image: '', layer_type: layer_type) }
        Then { expect(layer.printable?).to eq false }
      end

      context 'without image' do
        Given(:layer) { DummyLayerClass.create(image: '', filtered_image: 'bar', layer_type: layer_type) }
        Then { expect(layer.printable?).to eq true }
      end
    end

    context 'other types except photo' do
      Layer.layer_types.except('photo').keys.each do |layer_type|
        context "layer_type = #{layer_type}" do
          Given(:layer) { DummyLayerClass.create(layer_type: layer_type) }
          Then { expect(layer.printable?).to eq true }
        end
      end
    end
  end
end
