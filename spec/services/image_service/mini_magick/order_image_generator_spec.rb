require 'spec_helper'

describe ImageService::MiniMagick::OrderImageGenerator do
  subject { ImageService::MiniMagick::OrderImageGenerator.new(work) }

  describe '#generate' do
    let(:work) { double(:work, product_name: product_name) }

    context 'when work model is iPhone 4s/4' do
      let(:product_name) { 'iPhone 4s/4' }
      it 'generates iPhone 4 order image' do
        expect(subject).to receive(:generate_iphone_4_order_image)
        subject.generate
      end
    end

    context 'when work model is iPhone 5s/5' do
      let(:product_name) { 'iPhone 5s/5' }
      it 'generates iPhone 5s order image' do
        expect(subject).to receive(:generate_iphone_5s_order_image)
        subject.generate
      end
    end

    context 'when work model is iPad mini' do
      let(:product_name) { 'iPad mini' }
      it 'generates iPad mini order image' do
        expect(subject).to receive(:generate_ipad_mini_order_image)
        subject.generate
      end
    end

    context 'when work model is unsupported' do
      let(:product_name) { 'unsupported' }
      it 'generates default order image' do
        expect(subject).to receive(:generate_default_order_image)
        subject.generate
      end
    end
  end
end
