class Admin::AutoCouponsController < AdminController
  def index
    @auto_coupons = Coupon.auto_approved.page(params[:page] || 1)
  end

  def create
    coupon = Coupon.find_by!(code: params[:code])
    if coupon.auto_approve?
      redirect_to admin_auto_coupons_path, flash: { error: "#{coupon.code}已是自動審核！" }
    else
      coupon.update_column :auto_approve, true
      redirect_to admin_auto_coupons_path, flash: { success: "#{coupon.code}成功設定為自動審核！" }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to admin_auto_coupons_path, flash: { error: "找不到coupon：#{params[:code]}！" }
  end
end
