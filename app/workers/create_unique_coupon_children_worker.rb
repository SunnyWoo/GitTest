class CreateUniqueCouponChildrenWorker
  include Sidekiq::Worker

  def perform(id)
    coupon = Coupon.find(id)
    coupon.create_unique_coupon_children
  end
end
