class OrderPolicy < PrintPolicy
  # 打包，發貨，快遞公司，發票編號，訂單歷史，順豐訂單，出貨單
  # 出貨單背面，順豐電子運單，搜索訂單， 訂單處理進度, 隐藏訂單處理進度
  permit %i(package update_invoice history search delivery_note delivery_note_back
            schedule disable_schedule)
end
