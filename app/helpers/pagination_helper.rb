module PaginationHelper
  class RemoteLinkRenderer < BootstrapPagination::Rails
    def link(text, target, attributes = {})
      attributes['data-remote'] = true
      super
    end
  end
end
