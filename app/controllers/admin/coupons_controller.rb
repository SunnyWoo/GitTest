class Admin::CouponsController < Admin::ResourcesController
  def index
    @search = model_class.includes(:orders).root.ransack(params[:q])
    @resources = @search.result(distinct: true).order('id DESC').page(params[:page] || 1)
    respond_to do |format|
      format.html
      format.json { @coupons = @resources }
    end
  end

  def search
    @search = model_class.includes(:orders).root.ransack(params[:q].try(:merge, m: 'or'))
    @resources = @search.result(distinct: true).order('id DESC').page(params[:page] || 1)
  end

  def new
    super
    member.assign_attributes(
      usage_count_limit: 1,
      user_usage_count_limit: 1,
      apply_count_limit: 1,
      discount_type: 'fixed',
      price_tier: PriceTier.first,
      percentage: 0.1,
      condition: 'none',
      apply_target: 'once',
      base_price_type: 'special',
      code_type: 'base',
      code_length: 6,
      is_free_shipping: false,
      is_not_include_promotion: false
    )
    member.coupon_rules = [CouponRule.new(quantity: 1), CouponRule.new(quantity: 1)]
  end

  def edit
    super
    (2 - member.coupon_rules.size).times do
      member.coupon_rules << CouponRule.new
    end
  end

  def create
    params[:coupon][:coupon_rules_attributes] = params[:coupon][:coupon_rules].try(:values)
    @coupon = Coupon.new(admin_permitted_params.coupon)
    log_with_current_admin @coupon
    if @coupon.save
      render_coupon
    else
      respond_to do |f|
        f.html { render action: :new }
        f.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    params[:coupon][:coupon_rules_attributes] = params[:coupon][:coupon_rules].try(:values)
    @coupon = Coupon.find(params[:id])
    log_with_current_admin @coupon
    if @coupon.update(admin_permitted_params.coupon)
      render_coupon
    else
      respond_to do |f|
        f.html { render action: :edit }
        f.json { render json: @coupon.errors, status: :unprocessable_entity }
      end
    end
  end

  def code
    type = params[:type] || 'base'
    length = (params[:length] || 6).to_i
    render json: { code: Coupon.generate_code(type, length) }
  end

  def children
    @coupon = Coupon.find(params[:id])
    @q = @coupon.children.ransack(params[:q])
    @coupons = @q.result.page(params[:page])
    respond_to do |f|
      f.html
      f.csv do
        send_data CouponService.export_children(@coupon),
                  disposition: file_disposition(@coupon.title, 'csv')
      end
    end
  end

  def used_orders
    @coupon = Coupon.find params[:id]
    respond_to do |f|
      f.csv do
        send_data CouponService.export_used_orders(@coupon),
                  disposition: file_disposition(@coupon.title, 'csv')
      end
    end
  end

  def available_coupons
    respond_to do |f|
      f.csv do
        send_data CouponService.export_available_coupons,
          disposition: file_disposition('available_coupons', 'csv')
      end
    end
  end

  private

  def render_coupon
    respond_to do |f|
      f.html { redirect_to admin_coupons_path }
      f.json { render 'api/v3/coupons/show' }
    end
  end
end
