module Admin::LayoutsHelper
  # 設定每頁的 title, 會顯示在每頁的上方, 也會影響 <title> tag.
  # 可給個選擇性的 subtitle, 會變成小字顯示在主標題旁.
  def admin_title(title, subtitle: nil)
    @admin_title = title
    @admin_subtitle = subtitle
  end
end
