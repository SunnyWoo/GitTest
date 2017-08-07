require 'spec_helper'

describe UploadInventoryService do
  context '#inventory_type' do
    context 'WorkCodeInventory' do
      Given(:work_code) { create :work_code }
      Given(:service) { UploadInventoryService.new(work_code) }
      Then { service.send(:inventory_type) == UploadInventoryService::WorkCodeInventory }
    end

    context 'ProductModelInventory' do
      Given(:product_model) { create :product_model }
      Given(:service) { UploadInventoryService.new(product_model) }
      Then { service.send(:inventory_type) == UploadInventoryService::ProductModelInventory }
    end
  end

  describe 'WorkCodeInventory' do
    context '#yonyou_inventory_body' do
      Given(:user) { create :designer }
      Given(:work) { create :work, user: user }
      Given(:work_code) do
        WorkCode.create(work: work, user_id: user.id, user_type: 'Designer',
                        code: 'ABC', product_code: 'CODE-0000-ABC')
      end
      Given(:inventory) { UploadInventoryService::WorkCodeInventory.new(work_code) }
      Then {
        inventory.send(:inventory_body) == { inventory: { code: 'CODE-0000-ABC', name: work.name,
                                                          sort_code: '1', main_measure: '0102',
                                                          entry: [{ invcode: 'CODE-0000-ABC' }] } }
      }
    end

    context '#not_need_upload?' do
      context 'return false' do
        Given(:work_code) { create :work_code }
        before { allow(work_code).to receive(:designer?).and_return(false) }
        Given(:inventory) { UploadInventoryService::WorkCodeInventory.new(work_code) }
        Then { inventory.send(:not_need_upload?) == true }
      end

      context 'return true' do
        Given(:work_code) { create :work_code }
        before { allow(work_code).to receive(:designer?).and_return(true) }
        Given(:inventory) { UploadInventoryService::WorkCodeInventory.new(work_code) }
        Then { inventory.send(:not_need_upload?) == false }
      end
    end
  end

  describe 'ProductModelInventory' do
    context '#yonyou_inventory_body' do
      Given(:product) { create :product_model }
      Given(:inventory) { UploadInventoryService::ProductModelInventory.new(product) }
      Given(:inventory_body) { inventory.send(:inventory_body, 'CAPCG1WYPJ1-0000-000', '客制化') }

      Then {
        inventory_body == { inventory: { code: 'CAPCG1WYPJ1-0000-000', name: "客制化-#{product.name}",
                                         sort_code: '1', main_measure: '0102',
                                         entry: [{ invcode: 'CAPCG1WYPJ1-0000-000' }] } }
      }
    end
  end
end
