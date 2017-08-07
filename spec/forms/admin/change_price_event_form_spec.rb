require 'spec_helper'

describe Admin::ChangePriceEventForm do
  context '#save' do
    context 'when invalid' do
      Given(:form) { Admin::ChangePriceEventForm.new(ChangePriceEvent.new) }
      When { form.attributes = { target_ids: [] } }
      Then { form.invalid? }
      And { form.save == false }
      And { ChangePriceEvent.count == 0 }
    end

    context 'when valid' do
      Given(:form) { Admin::ChangePriceEventForm.new(ChangePriceEvent.new) }
      When { form.attributes = { target_ids: [1], price_tier_id: 1, target_type: 'ProductPrice' } }
      Then { form.valid? }
      And { form.save == true }
      And { ChangePriceEvent.count == 1 }
      And { ChangePriceEvent.last.aasm_state == 'processing' }
    end
  end
end
