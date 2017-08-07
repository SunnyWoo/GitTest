class FactoryMemberPolicy < PrintPolicy
  # 系統帳號, 更新帳號权限
  permit [:index, :update]
end
