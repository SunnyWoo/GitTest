namespace :guanyi do
  task sync_product_models: :environment do
    # load items
    serv = GuanyiService.new
    res = serv.request('gy.erp.items.get', page_no: '1', page_size: '50')
    items = res[:items]
    ProductModel.find_each do |pm|
      next if items.find { |item| item[:code] == pm.key }
      price = pm.price('CNY') || 0.0
      sales_price = BigDecimal.new(price.to_s)
      purchase_price = sales_price * 0.3
      agent_price = sales_price * 0.5
      cost = ('sticker' == pm.category.key ? 1 : 5)
      cost_price = purchase_price + cost

      puts "[準備新增] #{pm.key}: #{pm.name} #{sales_price}|#{purchase_price}|#{agent_price}|#{cost_price}"

      params = {
        code: pm.key,
        name: pm.name('zh-CN'),
        category_code: pm.category.key,
        simple_name: pm.name,
        supplier_code: 'commandp_factory',
        skus: [{ sku_code: pm.key, sku_name: pm.name }],
        purchase_price: purchase_price,
        sales_price: sales_price,
        agent_price: agent_price,
        cost_price: cost_price
      }
      serv.request('gy.erp.item.add', params)
    end
  end

  # 采购入库单会在次月财务结算之前建立
  task monthly_purchase: :environment do
    Purchase::ProductReference.collect_product_b2c_count
    Guanyi::SyncPurchaseOrders.sync_orders
    Purchase::History.create_histories
  end
end
