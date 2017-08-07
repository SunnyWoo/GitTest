class ImpositionPolicy < PrintPolicy
  # 新增拼板 更新拼板 删除拼板 拼板上傳 下載樣本 拼板歷史
  permit %i(create update destory upload download versions)
end
