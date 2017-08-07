# Public: Work Helper
#
# render_work_name(work) - work name 加上 cases，並截 45 字
# render_work_name_without_truncate(work) - work name 加上 cases，不截字
# render_work_name_with_device(work) - work name 加上 cases 與 作者名，並截 30 字
#
# Examples
#
#   render_work_name(work)
#   # => 'My Design iPhone 6 Cases'
#
# Returns the Work Helper.

module WorkHelper
  def render_string_with_br(strings, length = 20)
    tmp_string = []
    strings.split('').each_with_index do |string, index|
      tmp_string << string
      tmp_string << '<br />' if ((index + 1) % length) == 0
    end
    tmp_string.join().html_safe
  end

  def render_work_name(work, length = 45)
    truncate("#{work.product_name}", length: length)
  end

  def render_work_name_with_device(work)
    work_name =  render_string_with_br(truncate(work.name, length: 45), 23)
  	simple_format("<div class='cart-product-name'>#{work_name}</div><div>#{work.product_name}</div><div>by #{work.user_display_name}</div>")
  end

  def render_work_name_without_truncate(work)
  	work.product_name
  end

  def render_work_name_without_model(work, length = 40)
    truncate("#{work.name}", length: length)
  end

  def link_to_web_work(work, content)
    case
    when work.try(:is_public?)
      link_to content, shop_work_path(work.product, work)
    when work.archived?
      link_to content, archived_work_path(work)
    else
      link_to content, work_path(work)
    end
  end
end
