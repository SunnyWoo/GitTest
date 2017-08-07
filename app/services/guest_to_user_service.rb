class GuestToUserService
  class << self
    def migrate_data(from_user, to_user)
      return unless from_user.guest?
      migrate_work(from_user.id, to_user.id)
      migrate_order(from_user.id, to_user.id)
      migrate_device(from_user.id, to_user.id)
      migrate_wishlist(from_user.id, to_user.id)
      migrate_cart(from_user.id, to_user.id)
      from_user.role = :die
      from_user.migrate_to_user_id = to_user.id
      from_user.save!
    end

    def migrate_work(from_user_id, to_user_id)
      Work.where(user_id: from_user_id).find_each do |work|
        work.user_id = to_user_id
        work.save!
      end
    end

    def migrate_order(from_user_id, to_user_id)
      Order.where(user_id: from_user_id).find_each do |order|
        order.user_id = to_user_id
        order.save!
      end
    end

    def migrate_device(from_user_id, to_user_id)
      Device.where(user_id: from_user_id).find_each do |device|
        device.user_id = to_user_id
        device.save!
      end
    end

    def migrate_wishlist(from_user_id, to_user_id)
      from_user = User.find(from_user_id)
      to_user = User.find(to_user_id)
      tmp_wishlist = from_user.wishlist
      return unless tmp_wishlist
      normal_wishlist = to_user.wishlist || to_user.create_wishlist
      tmp_wishlist.items.update_all wishlist_id: normal_wishlist.id
    end

    def migrate_cart(from_user_id, to_user_id)
      CartMigrator.new(from_user_id, to_user_id).migrate
    end
  end

  class CartMigrator
    include CartRedis

    attr_reader :user_id, :store_id

    def initialize(from_user_id, to_user_id)
      @from_user_id = from_user_id
      @to_user_id = to_user_id
    end

    def migrate
      @user_id = @from_user_id
      cart_data = redis_get
      redis_del
      @user_id = @to_user_id
      redis_set(cart_data)
    end
  end
end
