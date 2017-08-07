require 'spec_helper'

describe InvoiceService do
  before do
    CurrencyType.create(name: 'USD', code: 'USD', rate: 30)
    CurrencyType.create(name: 'TWD', code: 'TWD', rate: 1)
    CurrencyType.create(name: 'JPY', code: 'JPY', rate: 0.27)
  end

  let(:coupon) { create(:percentage_coupon) }

  describe '#update_invoice_info' do
    context 'order with percentage_coupon ' do
      it 'check discount when currency TWD' do
        order = create(:order, :priced, coupon: coupon, currency: 'TWD').tap(&:reload)
                                                               .tap(&:save)
        order.update_invoice_info
        discount = Price.new(order.discount, order.currency)['TWD'].ceil
        expect(order.invoice_info['order_item_rows'].last['r12'].to_i)
                                                    .to(eq(- discount))
      end

      it 'check discount when currency USD' do
        order = create(:order, :priced, coupon: coupon, currency: 'USD').tap(&:reload)
                                                               .tap(&:save)
        order.update_invoice_info
        discount = Price.new(order.discount, order.currency)['TWD'].ceil
        expect(order.invoice_info['order_item_rows'].last['r12'].to_i).to(
          eq(- discount )
        )
      end
    end

    context 'shipping info country code' do
      it 'to TW' do
        order = create(:shipping_to_tw_order, :priced, currency: 'TWD').tap(&:reload)
                                                              .tap(&:save)
        order.update_invoice_info
        expect(order.shipping_info_country_code).to eq('TW')
        expect(order.invoice_info['order_row']['r06']).to eq(1)
        expect(order.invoice_info['order_row']['r20']).not_to eq('finance@commandp.com')
      end

      it 'to US' do
        order = create(:order, :priced).tap(&:reload).tap(&:save)
        order.update_invoice_info
        expect(order.shipping_info_country_code).to eq('US')
        expect(order.invoice_info['order_row']['r06']).to eq(2)
        expect(order.invoice_info['order_row']['r20']).to eq('finance@commandp.com')
      end
    end

    context 'order currency' do
      it 'with TWD' do
        order = create(:shipping_to_tw_order, :priced, currency: 'TWD').tap(&:reload)
                                                                       .tap(&:save)
        order.update_invoice_info
        expect(order.currency).to eq('TWD')
        expect(order.invoice_info['order_row']['r09']).to eq(2999.0)
      end

      it 'with USD' do
        order = create(:shipping_to_tw_order, :priced, currency: 'USD').tap(&:reload)
                                                                       .tap(&:save)
        order.update_invoice_info
        expect(order.currency).to eq('USD')
        expect(order.invoice_info['order_row']['r09']).to eq(2997.0)
      end

      it 'with JPY' do
        order = create(:shipping_to_tw_order, :priced, currency: 'JPY').tap(&:reload)
                                                                       .tap(&:save)
        order.update_invoice_info
        expect(order.currency).to eq('JPY')
        expect(order.invoice_info['order_row']['r09']).to eq(3240.0)
      end
    end

    context "when ENV['REGION'] = china" do
      it 'return nil' do
        stub_env('REGION', 'china')
        order = create(:order).tap(&:reload).tap(&:save)
        order.update_invoice_info
        expect(order.invoice_info).to be_nil
      end
    end
  end
end
