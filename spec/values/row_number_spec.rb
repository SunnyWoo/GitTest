require 'spec_helper'

describe RowNumber do
  Given(:data){ { a: 2, b: 4, c: 6, d: 8, e: 10 } }
  Given(:row_number) { RowNumber.new(nil, data) }

  context '#sum' do
    Then { row_number.sum == 30.0 }
  end

  context '#mean' do
    Then { row_number.mean == 6.0 }
  end

  context '#medium' do
    Then { row_number.medium == 6.0 }
    context 'with the even length' do
      Given(:row_number_for_mode) { RowNumber.new(nil, a: 2, b: 4, c: 6, d: 8, e: 10, f: 10) }
      Then { row_number_for_mode.medium == 7.0 }
    end
  end

  context '#mode' do
    Then { row_number.mode.nil? }
    context 'with mode existed' do
      Given(:row_number_for_mode) { RowNumber.new(nil, a: 2, b: 4, c: 6, d: 8, e: 10, f: 10) }
      Then { row_number_for_mode.mode == 10.0 }
    end
  end

  context '#length' do
    Then { row_number.length == 5 }
  end

  context '#variance' do
    Then { row_number.variance == 8.0 }
  end

  context '#standard_dev' do
    Then { row_number.standard_dev == 2.8284 }
  end

  context '#range' do
    Then { row_number.range == 8.0 }
  end

  context '#==' do
    context 'when equal' do
      Given(:row_number_2) { RowNumber.new('depends_on_hash_of_row_number', data) }
      Then { row_number == row_number_2 }
    end

    context 'when not equal' do
      Given(:row_number_2) { RowNumber.new(nil, data.slice(:a, :b)) }
      Then { row_number != row_number_2 }
    end
  end

  context '#where' do
    context 'return self if component includes all' do
      Then { row_number.where(component: :all) == row_number }
    end

    context 'return row_number for subset' do
      Then { row_number.where(component: %i(a b c)) == RowNumber.new(nil, data.slice(:a, :b, :c)) }
    end
  end
end
