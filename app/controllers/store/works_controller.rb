class Store::WorksController < Store::FrontendController
  before_action :find_store
  before_action :find_product_template, only: %w(create)
  before_action :find_cart, only: %w(preview)
  before_action :find_work, only: %w(edit preview update download)

  def edit
    # 注入編輯器的資料
    template = @work.product_template
    gon.editor_data = {
      oauth_config: {
        host: Settings.api_host,
        access_token: current_user_access_token,
      },
      quality_text: I18n.t('store.editor.quality_text'),
      work_uuid: @work.uuid,
      product_model: template.product.key,
      template: template.settings.merge!(transparent: 1,
                                         template_image: template.template_image.url,
                                         template_type: template.template_type_for_editor,
                                         max_width: template.settings.max_font_width,
                                         orientation: template.settings.rotation)
    }
    meta_setting(title: I18n.t('store.seo.editor_title', name: @store.name),
                 desc: I18n.t('store.seo.editor_desc', name: @store.name))
  end

  def create
    work = Work.new(
      name: 'My Design',
      product: @template.product,
      product_template: @template,
      work_type: 'is_private',
      user: current_user_or_guest,
      uuid: UUIDTools::UUID.timestamp_create.to_s
    )
    log_with_current_user work
    work.save!
    redirect_to edit_store_work_path(work, store_id: @store)
  end

  def share
    @work = Work.find(params[:id])

    meta_setting(
      title: I18n.t('store.seo.share_title', name: @store.name),
      desc: I18n.t('store.seo.share_desc', name: @store.name),
      image: @work.share_preview.try(:image_url)
    )

    if @work.user == current_user
      image = @work.previews.find_by(key: 'share').try(:url)
    else
      @templates = @store.templates.published
      # @other_works = @work.product_template.works.where.not(id: @work.id).finished.sorted('new').limit(6)
      render 'share_for_public'
    end
  end

  def preview
    gon.push store_id: @store.id, work_uuid: @work.uuid
    gon.data = {
      work_uuid: @work.uuid,
      access_token: current_user_access_token
    }
    meta_setting(title: I18n.t('store.seo.preview_title', name: @work.name),
                 desc: I18n.t('store.seo.preview_desc'))
  end

  def update
    if @work.update work_params
      head :ok
    else
      render json: { message: @work.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def download
    meta_setting(title: I18n.t('store.seo.download_title', name: @store.name),
                 desc: I18n.t('store.seo.download_desc', name: @store.name),
                 image: @work.share_preview.try(:image_url))
  end

  private

  def find_store
    @store = Store.find(params[:store_id])
  end

  def find_product_template
    @template = @store.templates.published.find(params[:template_id])
  end

  def find_work
    work_id = params[:id] || params[:work_id]
    @work = Store::WorkDecorator.new(current_user.works.find(work_id))
    redirect_to_store_page unless @work.product_template.present?
  rescue ActiveRecord::RecordNotFound
    redirect_to_store_page
  end

  def find_cart
    @cart = CartSession.new(controller: self, store_id: @store.id, user_id: current_user_or_guest.id)
  end

  def current_user_access_token
    if cookies[:access_token].present?
      cookies[:access_token]
    else
      current_user_or_guest
      current_user.access_token
    end
  end

  def work_params
    params.require(:work).permit(:share_text)
  end

  def redirect_to_store_page
    redirect_to store_path(params[:store_id])
  end
end
