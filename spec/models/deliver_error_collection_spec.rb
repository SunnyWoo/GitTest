# == Schema Information
#
# Table name: deliver_error_collections
#
#  id              :integer          not null, primary key
#  order_id        :integer
#  workable_id     :integer
#  workable_type   :string(255)
#  cover_image_url :text
#  print_image_url :text
#  error_messages  :json
#  aasm_state      :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe DeliverErrorCollection, type: :model do
  it 'FactoryGirl' do
    expect(build(:deliver_error_collection)).to be_valid
  end

  context 'associations' do
    it { should belong_to(:order) }
  end

  context 'AASM#event' do
    context 'repair' do
      Given(:deliver_error_collection) { create :deliver_error_collection }
      When { deliver_error_collection.repair! }
      Then { deliver_error_collection.reload.repairing? }
    end

    context 'finish' do
      Given(:deliver_error_collection) { create :deliver_error_collection, aasm_state: 'repairing' }
      When { deliver_error_collection.finish! }
      Then { deliver_error_collection.reload.completed? }
    end

    context 'failure' do
      Given(:deliver_error_collection) { create :deliver_error_collection, aasm_state: 'repairing' }
      When { deliver_error_collection.failure! }
      Then { deliver_error_collection.reload.failed? }
    end
  end

  context '#repair_images' do
    context 'success' do
      Given(:work) { create :work }
      Given(:deliver_error_collection) { create :deliver_error_collection, workable: work }
      When { deliver_error_collection.repair_images }
      Then { deliver_error_collection.reload.completed? }
    end

    context 'failed' do
      Given(:work) { create :work }
      Given(:deliver_error_collection) { create :deliver_error_collection, workable: work }
      before do
        allow(deliver_error_collection).to receive(:upload_images).and_return(false)
        allow(deliver_error_collection).to receive(:retrieve_image_urls).and_return([nil, nil])
        allow(deliver_error_collection).to receive(:retry_upload_images).and_return(false)
      end
      When { deliver_error_collection.repair_images }
      Then { deliver_error_collection.reload.failed? }
    end
  end
end
