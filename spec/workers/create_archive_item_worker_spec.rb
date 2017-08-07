require 'spec_helper'

describe CreateArchiveItemWorker do
  Given(:order_item) { create(:order_item) }

  describe 'order_item with itemable Work' do
    When { CreateArchiveItemWorker.new.perform(order_item.id) }
    Then { order_item.reload.itemable.is_a? ArchivedWork }
    And { order_item.versions.last.whodunnit == 'CreateArchiveItemWorker' }
  end

  describe 'fail when archived_work is not persisted' do
    Given(:work) { double('work', archived?: false) }
    Given(:archived_work) { ArchivedWork.new }
    before { expect(OrderItem).to receive(:find).and_return(order_item) }
    before { allow(order_item).to receive(:itemable).and_return(work) }
    before { expect(work).to receive(:last_archive).and_return(archived_work) }
    Then do
      expect { CreateArchiveItemWorker.new.perform(order_item.id) }
        .to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe 'order_item with itemable ArchivedWork' do
    Given(:archived_work) { create(:archived_work) }
    before { allow(archived_work).to receive(:last_archive) }
    When { order_item.update(itemable: archived_work) }
    When { CreateArchiveItemWorker.new.perform(order_item.id) }
    Then { order_item.reload.itemable.is_a? ArchivedWork }
    And { order_item.itemable == archived_work }
    And { expect(archived_work).not_to have_received(:last_archive) }
  end
end
