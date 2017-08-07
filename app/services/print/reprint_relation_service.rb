class Print::ReprintRelationService
  attr_accessor :print_item, :print_type, :package

  def initialize(id, print_type)
    @print_item = PrintItem.find(id)
    @print_type = print_type
    @package = print_item.package
  end

  def execute
    print_item.update(package_id: nil)
    # 客服退貨重印以外的重印要拆掉包裹
    if %w(factory_retprint warehouse_retprint upload_fail_reprint).include?(print_type)
      destroy_package
    end
  end

  private

  def revert_print_items_state
    package.print_items.each do |print_item|
      if print_item.order_item.delivered?
        print_item.revert_received!
      else
        print_item.revert_qualified!
      end
    end
  end

  def revert_order_items_state
    package.order_items.each do |order_item|
      if order_item.delivered?
        order_item.revert_received!
      elsif order_item.may_revert_qualified?
        order_item.revert_qualified!
      end
    end
  end

  def revert_print_items_to_unpackaged
    package.print_items.update_all(package_id: nil)
  end

  def destroy_package
    revert_print_items_state
    revert_order_items_state
    revert_print_items_to_unpackaged
    package.destroy!
  end
end
