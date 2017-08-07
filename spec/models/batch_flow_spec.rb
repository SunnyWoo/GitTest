# == Schema Information
#
# Table name: batch_flows
#
#  id                :integer          not null, primary key
#  aasm_state        :string(255)
#  factory_id        :integer
#  product_model_ids :integer          default([]), is an Array
#  print_item_ids    :integer          default([]), is an Array
#  batch_no          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  deadline          :datetime
#  locale            :string(255)
#

require 'spec_helper'

describe BatchFlow, type: :model do
  let(:factory) { create(:factory) }
  let(:batch_flow) { create(:batch_flow, factory_id: factory.id, product_model_ids: [product_model.id]) }
  let!(:product_model) { create(:product_model, factory_id: factory.id) }
  let!(:print_item) { create(:print_item, model_id: product_model.id).tap { |x| x.order.update_column(:aasm_state, :paid)} }
  let!(:product_model2) { create(:product_model) }
  let(:print_item2) { create(:print_item, model_id: product_model2.id).tap { |x| x.order.update_column(:aasm_state, :paid)} }

  # We skip this validation until it really processed by separated factories
  # describe '#validates_factory_match_product_model' do
  #   it 'return false' do
  #     expect(batch_flow.update(product_model_ids: [product_model2.id])).to be false
  #   end

  #   it 'return true' do
  #     expect(batch_flow.update(product_model_ids: [product_model.id])).to be true
  #   end
  # end

  context 'check define methon' do
    before do
      batch_flow.update(product_model_ids: [product_model.id])
      batch_flow.initial!
    end

    describe '#product_models' do
      it 'check product_models should include product_model' do
        expect(batch_flow.product_models.pluck(:id)).to eq([product_model.id])
      end
    end

    describe '#print_items' do
      it 'check print_items should include print_item' do
        expect(batch_flow.print_items.pluck(:id)).to eq([print_item.id])
      end
    end

    describe '#order_items' do
      it 'check print_items should include print_item' do
        expect(batch_flow.order_items.pluck(:id)).to eq([print_item.order_item_id])
      end
    end
  end

  context 'aasm_state' do
    it 'initial state' do
      expect(batch_flow.aasm.current_state).to eq(:pending)
      expect(batch_flow).to be_pending
      expect(batch_flow.product_model_ids.size).to be(1)
      expect(batch_flow.print_item_ids.size).to be(0)
    end

    it 'transitions initial' do
      expect(batch_flow).to be_pending
      expect(batch_flow.print_item_ids.size).to be(0)
      batch_flow.update(product_model_ids: [product_model.id])
      batch_flow.initial!
      expect(batch_flow).to be_initialized
      expect(batch_flow.print_item_ids.size).to be(1)
      expect(batch_flow.print_items.pluck(:aasm_state).uniq).to match_array(['uploading'])
    end
  end

  context 'event finish' do
    context 'execue enqueue_send_file_uploaded_notice_mail_job after complete' do
      Given(:processing_batch_flow) { create :batch_flow, aasm_state: :processing, product_model_ids: [product_model.id] }
      When { processing_batch_flow.finish }
      Then { assert 1, FactoryReminder.jobs.size }
      And { processing_batch_flow.activities(true).last.key == 'send_file_uploaded_mail' }
    end
  end

  context '#send_mail' do
    context 'when type is file_uploaded' do
      it 'has FactoryMailer to receive file_uploaded message' do
        expect(FactoryMailer).to receive(:file_uploaded).with(batch_flow.id, batch_flow.factory_id).and_call_original
        batch_flow.send_mail type: :file_uploaded
      end
    end

    context 'when type does not exist' do
      it 'raise error' do
        expect { batch_flow.send_mail type: :file_what? }.to raise_error(RuntimeError)
      end
    end
  end

  context 'valid locale' do
    it { expect(batch_flow).to be_valid }
    it 'return false when locale is gg' do
      batch_flow.locale = 'gg'
      expect(batch_flow).not_to be_valid
    end

    Factory::LOCALES.each do |locale|
      it "return true when locale is #{locale}" do
        batch_flow.locale = locale
        expect(batch_flow).to be_valid
      end
    end
  end
end
