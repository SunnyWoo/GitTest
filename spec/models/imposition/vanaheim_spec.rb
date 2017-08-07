# == Schema Information
#
# Table name: impositions
#
#  id                       :integer          not null, primary key
#  model_id                 :integer
#  paper_width              :float
#  paper_height             :float
#  definition               :json
#  created_at               :datetime
#  updated_at               :datetime
#  sample                   :string(255)
#  rotate                   :integer
#  type                     :string(255)
#  template                 :string(255)
#  demo                     :boolean          default(FALSE), not null
#  file                     :string(255)
#  flip                     :boolean          default(FALSE)
#  flop                     :boolean          default(FALSE)
#  include_order_no_barcode :boolean          default(FALSE)
#

require 'spec_helper'

describe Imposition::Vanaheim do
  describe '#localized_labels' do
    let(:print_item) { create(:print_item) }

    context 'when content is plain text' do
      let(:imposition) do
        Imposition::Vanaheim.new(labels: [
          { name: 'OrderNumber', contents: [
            { locale: 'zh-TW', content: '訂單編號' },
            { locale: 'en', content: 'Order Number' }
          ] }
        ])
      end

      it 'returns correct label' do
        expect(imposition.localized_labels(print_item)).to eq([{ name: 'OrderNumber', content: '訂單編號' }])
      end
    end

    context 'when content contains variables' do
      let(:imposition) do
        Imposition::Vanaheim.new(labels: [
          { name: 'OrderNumber', contents: [
            { locale: 'zh-TW', content: '訂單編號: %{order_number}' },
            { locale: 'en', content: 'Order Number: %{order_number}' }
          ] },
          { name: 'ProductName', contents: [
            { locale: 'zh-TW', content: '產品: %{product_name}' },
            { locale: 'en', content: 'Product: %{product_name}' }
          ] }
        ])
      end

      it 'returns correct label' do
        expect(imposition.localized_labels(print_item)).to eq([
          { name: 'OrderNumber', content: "訂單編號: #{print_item.order_item.order.order_no}" },
          { name: 'ProductName', content: "產品: #{print_item.order_item.itemable.product_name}" }
        ])
      end
    end
  end

  # test in zh-TW
  around do |example|
    original_locale = I18n.locale
    I18n.locale = 'zh-TW'
    example.run
    I18n.locale = original_locale
  end
end
