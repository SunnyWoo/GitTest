class NotePolicy < PrintPolicy
  # 新增留言， 编辑留言
  permit %i(create update)
end
