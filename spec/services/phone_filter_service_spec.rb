require 'spec_helper'

describe PhoneFilterService do
  context '.run' do
    context 'returns all phones in valid_phones without invalid_phone' do
      Given(:phones) { %w(0911222333 0933_444_555 0944-555-666) }
      When(:result) { PhoneFilterService.run(phones) }
      Then { expect(result.first).to eq '0911222333,0933444555,0944555666' }
      And { expect(result.last).to be_blank }
    end

    context 'distinguishes phones from invalid format' do
      Given(:phones) { %w(0911222333 0933_444_555 0944-555-666 123123 1235425 09223345) }
      When(:result) { PhoneFilterService.run(phones) }
      Then { expect(result.first).to eq '0911222333,0933444555,0944555666' }
      And { expect(result.last).to eq '123123,1235425,09223345' }
    end

    context 'recognize china phone format' do
      Given(:phones) { %w(112-3456-7890 123-4567_8901 321_3456_7890 123456789012) }
      When(:result) { PhoneFilterService.run(phones) }
      Then { expect(result.first).to eq '11234567890,12345678901' }
      And { expect(result.last).to eq '321_3456_7890,123456789012' }
    end
  end
end
