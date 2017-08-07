class PackagePolicy < PrintPolicy
  # 包裹搜尋 打包，發貨，順豐訂單, 順豐電子運單 出貨單
  permit %i(index create ship sf_express sf_express_waybill delivery_note)
end
