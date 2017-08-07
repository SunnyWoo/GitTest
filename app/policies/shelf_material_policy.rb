class ShelfMaterialPolicy < PrintPolicy
  permit %i(index create update stock activities adjust)
end
