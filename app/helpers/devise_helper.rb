module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?
    messages = resource.errors.full_messages.map { |msg| msg + tag(:br) }.join
    messages.html_safe
  end

  def devise_error_messages?
    resource.errors.empty? ? false : true
  end

  def sign_up_errors(messages)
    messages = messages.split(',').map { |msg| msg + tag(:br) }.join
    messages.html_safe
  end
end
