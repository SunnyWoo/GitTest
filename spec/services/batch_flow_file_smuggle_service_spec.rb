require 'spec_helper'

describe BatchFlowFileSmuggleService do
  Given(:factory) { create(:factory) }
  Given!(:product_model) { create(:product_model, factory_id: factory.id) }
  Given!(:batch_flow) { create :batch_flow, product_model_ids: [product_model.id] }
  Given(:source_path) { Rails.root + 'spec/fixtures/batch_flow_source' }
  context '#initialize' do
    Then { expect { BatchFlowFileSmuggleService.new('not_a_id', source_path) }.to raise_error(ActiveRecord::RecordNotFound) }
    And { expect { BatchFlowFileSmuggleService.new(batch_flow.id, 'wtf') }.to raise_error(DirectoryMissingError) }
    And { expect { BatchFlowFileSmuggleService.new(batch_flow.id, source_path) }.not_to raise_error }
  end

  context 'execute' do
    Given(:smuggler) { BatchFlowFileSmuggleService.new(batch_flow.id, source_path) }
    context 'it uploads zip to batch_flow file' do
      When { smuggler.execute }
      Then { expect(batch_flow.reload.attachments).to be_any }
      And { !File.exist?smuggler.output_folder }
    end
  end
end
