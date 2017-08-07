class Mobile::RedeemWorksController < MobileController
  before_action :find_work, only: 'edit'
  before_action :find_redeem_work, only: 'preview'

  def create
    product = ProductModel.find_by!(key: params[:model_key])
    # should use redeemable_on('website') scope

    @work = Work.create(
      name: product.name,
      product: product,
      work_type: 'is_private',
      user: current_user,
      uuid: UUIDTools::UUID.timestamp_create.to_s
    )

    redirect_to edit_mobile_redeem_work_path(id: @work.uuid)
  end

  def edit
    @editor = {
      host: "#{request.protocol}#{request.host}",
      access_token: session[:access_token],
      product_model: @work.product.key,
      work_uuid: @work.uuid
    }
  end

  def preview
    @previews = @work.respond_to?(:ordered_previews) ? @work.ordered_previews : @work.previews
    @previews = @previews.dup
    @first_image = @previews.shift
  end

  protected

  def find_work
    @work = Work.find_by!(uuid: params[:id])
  end

  def find_redeem_work
    @work = GlobalID::Locator.locate_signed(params[:id])
    not_found_error unless @work
  end
end
