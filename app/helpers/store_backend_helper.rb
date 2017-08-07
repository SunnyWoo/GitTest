module StoreBackendHelper
  def active_if_controller(controller_name)
    'active' if params[:controller].include? controller_name
  end

  # 當網址為目前頁面時，將連結變成 '#'，用在 navigation bar 的連結
  def link_to_anchor_if_current(content, *args)
    link_to_unless_current(content, *args) do
      link_to content, '#', *args[1..-1]
    end
  end

  # 從 gem 'gretel' 中拿到當前頁面標題
  def title_from_breadcrumb
    gretel_renderer.send(:links).try(:last).try(:text)
  end

  # 產聲 INSPINIA Theme 的 ibox
  def panel(title: nil, title_html: nil, **html_options)
    locals = { title: title, title_html: title_html, html_options: html_options }

    render layout: 'store/backend/shared/panel', locals: locals do
      yield if block_given?
    end
  end
end
