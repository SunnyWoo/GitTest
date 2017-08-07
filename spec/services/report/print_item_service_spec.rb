require 'spec_helper'

describe Report::PrintItemService do
  context '#execute' do
    context 'validates fail' do
      it 'returns error when args nil' do
        expect{ Report::PrintItemService.new.execute }.to raise_error(ApplicationError)
      end

      it 'returns error when month unvalid' do
        expect{ Report::PrintItemService.new(month: 13).execute }.to raise_error(ByStar::ParseError)
      end

      it 'returns error when day unvalid' do
        expect{ Report::PrintItemService.new(day: '2015-01-99').execute }.to raise_error(ByStar::ParseError)
      end
    end

    context 'returns csv' do
      before do
        print_item = create(:print_item)
        print_item.upload!
        print_item.print!
        print_item.sublimate!
        print_item.check!
        create(:currency_type)
        create(:cny_currency_type)
      end

      it 'by month' do
        month = Time.zone.now.month
        expect(PrintHistory.count).not_to eq(0)
        expect(Report::PrintItemService.new(month: month).execute).not_to be nil
        expect(Report::PrintItemService.new(month: month).rows.first.first).to eq(
          PrintHistory.first.print_item.order.order_no
        )
      end

      it 'by month and year' do
        month = Time.zone.now.month
        year = Time.zone.now.year
        expect(PrintHistory.count).not_to eq(0)
        expect(Report::PrintItemService.new(month: month, year: year).execute).not_to be nil
        expect(Report::PrintItemService.new(month: month, year: year).rows.first.first).to eq(
          PrintHistory.first.print_item.order.order_no
        )
      end

      it 'by day' do
        today = Date.today.to_s
        expect(PrintHistory.count).not_to eq(0)
        expect(Report::PrintItemService.new(day: today).execute).not_to be nil
        expect(Report::PrintItemService.new(day: today).rows.first.first).to eq(
          PrintHistory.first.print_item.order.order_no
        )
        expect(Report::PrintItemService.new(day: Time.zone.yesterday).execute).not_to be nil
      end
    end
  end
end
