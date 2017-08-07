class Admin::CollectionsController < Admin::ResourcesController
  before_action :find_collection, only: %w(works tags add_tag remove_tag work_position
                                           update_work_position remove_work_position)
  before_action :find_work, only: %w(work_position update_work_position remove_work_position)

  def new
    super
    I18n.available_locales.each do |locale|
      @resource.translations.build(locale: locale)
    end
  end

  def works
    @active = 'works'
    params[:work_type] ||= 'StandardizedWork'
    all_works = get_works
    @search = all_works.ransack(params[:q])
    @works = @search.result.page(params[:page])
  end

  def tags
    @active = 'tags'
    params[:q] ||= {}
    @search = Tag.includes(:collection_tags).order('collection_tags.id').ransack(params[:q])
    @tags = @search.result.page(params[:page])
    render :works
  end

  def add_tag
    if params[:tag_ids]
      @collection.tag_ids += params[:tag_ids]
      flash[:notice] = I18n.t('collections.add_success')
    end
    redirect_to :back
  end

  def remove_tag
    tag = Tag.find(params[:tag_id])
    @collection.remove_tag(tag)
    flash[:notice] = I18n.t('collections.remove_success')
    redirect_to :back
  end

  def work_position
  end

  def update_work_position
    owner_position = @work.collection_works.find_by(collection_id: @collection.id).try(:position)
    other_collection_work = @collection.collection_works.find_by(position: params[:position])
    owner_collection_work = @work.collection_works.find_or_create_by(collection_id: @collection.id)
    owner_collection_work.update_attribute(:position, params[:position])
    other_collection_work.update_attribute(:position, owner_position) if other_collection_work
    redirect_to :back
  end

  def remove_work_position
    @work.collection_works.find_by(collection_id: @collection.id).destroy
    redirect_to :back
  end

  private

  def find_collection
    @collection = Collection.find(params[:id])
  end

  def find_work
    @work = work_class.joins(tags: :collection_tags)
                      .where(id: params[:work_id], collection_tags: { collection_id: @collection.id }).first
  end

  def association_objects
    case params[:work_type]
    when 'Work' then 'works'
    when 'StandardizedWork' then 'standardized_works'
    else
      fail RecordNotFoundError
    end
  end

  def work_class
    params[:work_type] ||= 'StandardizedWork'
    @work_type = params[:work_type]
    params[:work_type] == 'StandardizedWork' ? StandardizedWork : Work
  end

  def get_works
    work_class.includes({ taggings: { tag: :collections } }, :collection_works)
              .where('collections.id = ?', @collection.id)
              .order("collection_works.position, #{association_objects}.id desc")
  end
end
