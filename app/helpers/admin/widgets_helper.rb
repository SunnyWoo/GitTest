module Admin::WidgetsHelper
  # 畫一個 widget 出來.
  #
  # title - 標題, 接受字串或 Symbol
  # icon - FontAwesome 的 icon 名, 沒指定的話就用 'table'
  # toolbar - 顯示在 widget 的最右上的按鈕們之類的, 接受字串或 Symbol
  # content - 內容, 接受字串或 Symbol
  #
  # 所有接受字串或 Symbol 的欄位都會根據是否為 Symbol 來決定是否 yield content
  def render_widget(title: nil, icon: 'table', toolbar: nil, content: nil)
    render 'admin/shared/widget', title: text_or_yield_content(title),
                                  icon: icon,
                                  toolbar: text_or_yield_content(toolbar),
                                  content: text_or_yield_content(content)
  end

  def text_or_yield_content(value)
    return if value.nil?
    if value.is_a?(Symbol)
      content_for(value)
    else
      value.to_s
    end
  end
end
