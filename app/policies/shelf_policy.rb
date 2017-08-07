class ShelfPolicy < PrintPolicy
  # 新增貨品，編輯貨品，取貨,盤點調整和調撥，上架，移貨，倉儲貨架記錄，導出CSV, 反架, 盤點調整
  permit %i(create update change stock move activities export_csv restore adjust)
end
