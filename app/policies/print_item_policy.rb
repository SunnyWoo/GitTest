class PrintItemPolicy < PrintPolicy
  # 熱轉印，上傳，重印，遲到記錄，重印記錄, 下載原圖, 抛单确认完成, 質檢記錄
  # 商品處理進度 隐藏商品處理進度
  permit %i(sublimate print reprint delayed reprint_list download_img
            receive qualified_report schedule disable_schedule)
end
