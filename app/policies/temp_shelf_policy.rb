class TempShelfPolicy < PrintPolicy
  # 放入暫存區，更新暫存區
  permit %i(create update)
end
