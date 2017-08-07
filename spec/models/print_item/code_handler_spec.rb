require 'spec_helper'

describe PrintItem::CodeHandler do
  Given(:timestamp_no) { Timestamp.today_timestamp_no }

  context 'encode' do
    context 'return nil when timestamp_no is nil' do
      When(:result) { PrintItem::CodeHandler.encode(nil) }
      Then { result.nil? }
    end

    context 'return code when timestamp_no is valid' do
      When(:result) { PrintItem::CodeHandler.encode('20167140004') }
      Then { result == 'C16-6PSL4' }
    end
  end

  context 'decode' do
    context "return code when code is not include '-'" do
      When(:result) { PrintItem::CodeHandler.decode('123321') }
      Then { result == '123321' }
    end

    context 'return timestamp_no when timestamp_no is valid' do
      Given(:code) { PrintItem::CodeHandler.encode(timestamp_no) }
      When(:result) { PrintItem::CodeHandler.decode(code) }
      Then { result == timestamp_no.to_s }
    end
  end
end
