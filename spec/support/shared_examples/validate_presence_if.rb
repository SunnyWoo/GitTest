shared_examples_for 'validate presence if' do |attr, condition, msg = nil|
  context "#validate #{attr}" do
    context "when #{condition} true" do
      When { allow(subject).to receive(condition).and_return(true) }
      if msg
        Then { expect(subject).to validate_presence_of(attr).with_message(msg) }
      else
        Then { expect(subject).to validate_presence_of(attr) }
      end
    end
    context 'otherwise' do
      When { allow(subject).to receive(condition).and_return(false) }
      Then { expect(subject).not_to validate_presence_of(attr) }
    end
  end
end
