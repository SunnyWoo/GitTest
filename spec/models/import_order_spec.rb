# == Schema Information
#
# Table name: import_orders
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  aasm_state :string(255)
#  failed     :json
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ImportOrder, type: :model do
  Given!(:user) { create :user, email: 'guanyi@commandp.com' }
  context 'validation' do
    it { should validate_presence_of(:file) }
    it { should have_many(:succeeds) }
  end

  context '#import_sync' do
    Given!(:import_order) { create :import_order }
    Then { ImportOrdersWorker.jobs.size == 1 }
  end

  context '#import!' do
    Given(:import_order) { create :import_order }
    When { import_order.import! }
    Then { import_order.importing? }
  end

  context '#finish!' do
    Given(:import_order) { create :import_order, aasm_state: 'importing' }
    When { import_order.finish! }
    Then { import_order.finished? }
  end

  context '#generate_orders' do
    Given(:failed) { [{ platform_code: '54321', message: 'OrderExistedError' }] }
    before do
      Guanyi::ImportOrder.any_instance.stub(:failed).and_return(failed)
      Guanyi::ImportOrder.any_instance.stub(:build_order).and_return(true)
      Guanyi::ImportOrder.any_instance.stub(:platform_codes).and_return(['54321'])
    end
    Given(:import_order) { create :import_order }
    When { import_order.generate_orders }
    Then { import_order.failed.as_json == failed.as_json }
  end

  context '#failed_retry' do
    Given(:failed) { [{ platform_code: '54321', message: 'OrderExistedError' }] }
    before do
      Guanyi::ImportOrder.any_instance.stub(:failed).and_return({})
      Guanyi::ImportOrder.any_instance.stub(:build_order).and_return(true)
      Guanyi::ImportOrder.any_instance.stub(:platform_codes).and_return(['54321'])
    end
    Given(:import_order) { create :import_order, failed: failed }
    When { import_order.failed_retry }
    Then { import_order.failed.as_json.blank? }
  end
end
