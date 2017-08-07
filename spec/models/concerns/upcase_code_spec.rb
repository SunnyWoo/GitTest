require 'spec_helper'

Temping.create :dummy_upcase_code do
  with_columns do |t|
    t.string :code
  end
  include UpcaseCode
end

describe UpcaseCode do
  context 'callback #upcase_code' do
    Given(:dummy) { DummyUpcaseCode.create code: 'Abc' }
    Then { dummy.code == 'ABC' }
  end
end
