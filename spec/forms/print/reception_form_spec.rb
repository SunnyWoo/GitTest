require 'spec_helper'

describe Print::ReceptionForm do
  describe '#save' do
    Given!(:print_item) { create :print_item, :with_delivering }
    Given(:form) { Print::ReceptionForm.new(print_item) }
    Given(:temp_shelf) { print_item.temp_shelf }

    context 'receive only' do
      Given(:params) do
        { state: 'received_only' }
      end

      When(:ans) do
        form.attributes = params
        form.save
      end
      Then { expect(ans).to eq true }
      And { expect(print_item.reload).to be_received }
      And { expect(temp_shelf).to eq nil }
    end

    context 'receive and move to temp shelf' do
      Given(:params) do
        {
          state: 'received_on_temp_shelf',
          serial: 'FOO',
          description: 'BAR'
        }
      end

      When(:ans) do
        form.attributes = params
        form.save
      end
      Then { expect(ans).to eq true }
      And { expect(print_item.reload).to be_qualified }
      And { expect(temp_shelf.serial).to eq 'FOO' }
      And { expect(temp_shelf.description).to eq 'BAR' }
    end

    context 'validations' do
      context 'invalid state' do
        Given(:params) do
          {
            state: 'wrong_state',
            serial: 'FOO',
            description: 'BAR'
          }
        end

        When { form.attributes = params }
        Then { expect(form.valid?).to eq false }
        And { expect(form.errors[:state]).to be_present }
      end

      context 'required serial when received_on_temp_shelf' do
        Given(:params) do
          {
            state: 'received_on_temp_shelf',
            description: 'BAR'
          }
        end

        When { form.attributes = params }
        Then { expect(form.valid?).to eq false }
        And { expect(form.errors[:serial]).to be_present }
      end
    end
  end
end
