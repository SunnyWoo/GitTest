class MergeUserService < GuestToUserService
  class << self
    def migrate_data(from_user, to_user)
      fail ParametersInvalidError unless all_users?(from_user, to_user)
      fail AlreadySameUserError, 'Already the same user' if from_user == to_user
      migrate_work(from_user.id, to_user.id)
      migrate_order(from_user.id, to_user.id)
      migrate_device(from_user.id, to_user.id)
      migrate_wishlist(from_user.id, to_user.id)
      migrate_tokens(from_user.id, to_user.id)
      migrate_cart(from_user.id, to_user.id)
      from_user.update_attributes(role: :die, migrate_to_user_id: to_user.id)
    end

    def migrate_tokens(from_user_id, to_user_id)
      Omniauth.where(owner_type: 'User', owner_id: from_user_id).update_all(owner_id: to_user_id)
    end

    def all_users?(from_user, to_user)
      from_user.is_a?(User) && to_user.is_a?(User)
    end
  end
end
