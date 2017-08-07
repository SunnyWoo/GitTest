require "spec_helper"

describe ApplicationHelper, type: :helper do
  before do
    @usd_ct = CurrencyType.find_by!(code: 'USD')
    @twd_ct = CurrencyType.find_by!(code: 'TWD')
  end

  describe "#render_price" do
    context 'CurrencyType is USD' do
      it "return $999.99" do
        expect(helper.render_price(999.99, currency_code: @usd_ct.code)).to eq('$999.99')
      end
    end

    context 'CurrencyType is TWD' do
      it "return NT$999" do
        expect(helper.render_price(999.99, currency_code: @twd_ct.code)).to eq('NT$999')
      end
    end
  end

  describe "#currency_code_precision" do
    context 'CurrencyType is USD' do
      it "return 2" do
        expect(helper.currency_code_precision(@usd_ct.code)).to eq(2)
      end
    end

    context 'CurrencyType is TWD' do
      it "return 2" do
        expect(helper.currency_code_precision(@twd_ct.code)).to eq(0)
      end
    end
  end
end