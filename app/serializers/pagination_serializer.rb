# NOTE: not used in v3 api, remove me later
class PaginationSerializer < ActiveModel::ArraySerializer
  def initialize(object, options = {})
    meta_key = options[:meta_key] || :meta
    options[meta_key] ||= {}
    options[meta_key][:pagination] = {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.previous_page,
      total_entries: object.total_entries,
      total_pages: object.total_pages
    }
    super(object, options)
  end
end
