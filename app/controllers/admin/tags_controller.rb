class Admin::TagsController < Admin::ResourcesController
  include TagCreator

  before_action :find_tag, only: %w(works tagging_position
                                    update_tagging_position remove_tagging_position)
  before_action :find_tagging, only: %w(tagging_position update_tagging_position
                                        remove_tagging_position)

  def index
    super
    respond_to do |f|
      f.html
      f.json do
        @tags = @resources
        render 'api/v3/tags/index'
      end
    end
  end

  def new
    super
    I18n.available_locales.each do |locale|
      @resource.translations.build(locale: locale)
    end
  end

  def works
    params[:work_type] ||= 'StandardizedWork'
    @work_type = params[:work_type]
    @search = @tag.work_taggings.where(taggable_type: params[:work_type]).ransack(params[:q])
    @tag_taggings = @search.result.order('position asc, taggable_id desc')
  end

  def all_works
    @search = work_class.is_public.ransack(params[:q])
    @works = @search.result.order('id desc').page(params[:page])
  end

  def work_tags
    @update_type = params[:update_type] == 'apply' ? '+' : '-'
    @update_ids = create_new_tag(params[:tag_ids])
    if params[:work_ids].present?
      update_work_tags(params[:work_ids][:Work])
      update_standardized_work_tags(params[:work_ids][:StandardizedWork])
    end
    redirect_to :back
  end

  def tagging_position
  end

  def update_tagging_position
    old_position = @tagging.position
    position_tagging = @tag.work_taggings.where(taggable_type: @tagging.taggable_type, position: params[:position]).first
    @tagging.update_attribute(:position, params[:position])
    position_tagging.update_attribute(:position, old_position) if position_tagging
    redirect_to :back
  end

  def remove_tagging_position
    @tagging.update_attribute(:position, nil)
    redirect_to :back
  end

  private

  def find_tag
    @tag = Tag.find(params[:id])
  end

  def find_tagging
    @tagging = @tag.taggings.find(params[:tagging_id])
  end

  def update_work_tags(work_ids)
    Work.where(id: work_ids).each do |work|
      work.tag_ids = work.tag_ids.send(@update_type, @update_ids)
    end
  end

  def update_standardized_work_tags(work_ids)
    StandardizedWork.where(id: work_ids).each do |work|
      work.tag_ids = work.tag_ids.send(@update_type, @update_ids)
    end
  end

  def work_class
    params[:work_type] ||= 'StandardizedWork'
    @work_type = params[:work_type]
    params[:work_type] == 'StandardizedWork' ? StandardizedWork : Work
  end
end
