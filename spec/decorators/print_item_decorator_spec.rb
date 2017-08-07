require 'spec_helper'

describe PrintItemDecorator do
  Given(:decorator) { PrintItemDecorator.new(print_item) }
  describe '#product_by_other_factory?' do
    Given(:print_item) { create :print_item, product: product }
    context 'normal product' do
      Given(:product) { create :product_model }
      Then { expect(decorator.product_by_other_factory?).to eq false }
    end

    context 'delivered(transfered) production' do
      Given(:product) { create :product_model, remote_key: 'foo' }
      Then { expect(decorator.product_by_other_factory?).to eq true }
    end

    context 'external production (like wonder)' do
      Given(:product) { create :product_model, external_code: 'bar' }
      Then { expect(decorator.product_by_other_factory?).to eq true }
    end
  end

  describe '#shelving?' do
    context 'an item had received' do
      Given(:print_item) { create :print_item, aasm_state: 'received' }
      Then { expect(decorator.shelving?).to eq true }
    end

    context 'an item had qualified' do
      Given(:print_item) { create :print_item, aasm_state: 'qualified' }
      Then { expect(decorator.shelving?).to eq true }
    end

    context 'an item had not receved' do
      Given(:print_item) { create :print_item, aasm_state: 'delivering' }
      Then { expect(decorator.shelving?).to eq false }
    end
  end
end
