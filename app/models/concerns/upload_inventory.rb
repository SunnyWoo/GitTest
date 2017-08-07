module UploadInventory
  extend ActiveSupport::Concern

  included do
    after_commit :upload_inventory, on: :create, if: :china?
  end

  private

  def upload_inventory
    # UploadInventoryService.new(self).upload
  end

  def china?
    Region.china?
  end
end
