module TagCreator
  private

  def create_new_tag(tag_ids)
    fail InvalidError.new(caused_by: I18n.t('tags.index.page_title')) unless tag_ids
    tag_ids.select(&:present?).map do |tag_id|
      tag = Tag.find_by_id(tag_id)
      tag = Tag.create_by_name(tag_id) if tag.blank?
      tag.id
    end
  end

  def set_tag_ids(model)
    model = model.to_sym
    params[model][:tag_ids] = [] if params[model][:tag_ids].nil?
    params[model][:tag_ids] = create_new_tag(params[model][:tag_ids])
  end
end
