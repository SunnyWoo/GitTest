require 'spec_helper'

describe PrintItem::CodeQuery do
  Given(:print_item) { create :print_item, timestamp_no: Timestamp.today_timestamp_no }

  context 'result' do
    context 'search with code' do
      Given(:code) { PrintItem::CodeHandler.encode(print_item.timestamp_no) }
      When(:result) { PrintItem::CodeQuery.new(code).result }
      Then { result == [print_item] }
    end

    context 'search with timestamp_no' do
      When(:result) { PrintItem::CodeQuery.new(print_item.timestamp_no).result }
      Then { result == [print_item] }
    end
  end
end
