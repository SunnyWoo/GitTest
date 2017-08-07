class FactoryRoleGroupPolicy < PrintPolicy
  # 权限群组列表， 創建權限群組， 更新權限群組
  permit %i(index create update)
end
