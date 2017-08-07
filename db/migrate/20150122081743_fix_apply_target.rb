class FixApplyTarget < ActiveRecord::Migration
  def change
    Coupon.update_all(apply_target: 'once')
  end

  class Coupon < ActiveRecord::Base
  end
end
