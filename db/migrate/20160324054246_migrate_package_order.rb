class MigratePackageOrder < ActiveRecord::Migration
  def change
    # china-staging 已经做过迁移了 多以加个判断条件
    return if Package.all.size > 1

    # 查看现有的订单 是否有可以被拼单的
    Order.includes(:shipping_info).paid.find_each do |order|
      order.send(:mark_merge_target_ids) if order.send(:can_merge_order?)
    end

    # 将已经被打包的订单打包到Package
    Order.includes( :order_items).where(aasm_state: :packaged).find_each do |order|
      next if order.print_items.where(aasm_state: 'onboard').blank?
      order.order_items.where(aasm_state: 'onboard').update_all(aasm_state: 'qualified')
      order.print_items.where(aasm_state: 'onboard').update_all(aasm_state: 'qualified')
      order.update_column(:aasm_state, :paid)
      print_item_ids = order.print_items.where(aasm_state: 'qualified').pluck(:id)
      Package.create_package_with_print_items(print_item_ids: print_item_ids)
    end

    # 将已发货的订单做成包裹
    Order.includes(:print_items, :order_items, :shipping_info).shipping.find_each do |order|
      if order.print_items.present?
        order.transaction do
          package = Package.create(aasm_state: 'shipping')

          order.print_items.update_all(package_id: package.id, aasm_state: :onboard)
          order.order_items.update_all(aasm_state: :shipping)

          # 历史订单 要把原本的订单号作为现在的包裹号, 以便可以追溯到顺丰运单的物流信息
          package.package_no = order.order_no
          package.ship_code = order.ship_code
          package.save!

          # 跳过验证
          package.build_shipping_info(order.shipping_info.try(:clone_shipping_info_attributes))
          package.shipping_info.save!(validate: false)

          package.create_activity(:migrated, original_state: 'shipping')
          # 迁移顺丰物流信息
          order.waybill_routes.update_all(package_id: package.id)
        end
      else
        Rails.logger.info("order migrate to pacakge error, order_id: #{order.id}")
      end
    end

    # 处理存在退款的订单
    # 如果没有包裹号就算没有发过货, 不需要迁移到包裹
    Order.includes(:print_items).where(aasm_state: %w(refunding refunded part_refunding part_refunded)).where.not(ship_code: nil).find_each do |order|
      if order.print_items.present?
        package = Package.create(aasm_state: 'shipping')

        order.print_items.update_all(package_id: package.id, aasm_state: :onboard)
        order.order_items.update_all(aasm_state: :shipping)

        package.package_no = order.order_no
        package.ship_code = order.ship_code
        package.save!

        package.build_shipping_info(order.shipping_info.try(:clone_shipping_info_attributes))
        package.shipping_info.save!(validate: false)

        package.create_activity(:migrated, original_state: order.aasm_state)
        order.waybill_routes.update_all(package_id: package.id)
      else
        Rails.logger.info("order migrate to pacakge error, order_id: #{order.id}")
      end
    end
  end
end

class BillingProfile < ActiveRecord::Base
  private

  def downcase_email
    self.email = email.try(:downcase)
  end
end
