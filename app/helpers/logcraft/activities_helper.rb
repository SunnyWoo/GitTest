module Logcraft::ActivitiesHelper
  def render_activities(activities)
    render partial: 'logcraft/activities', locals: { activities: activities }
  end

  def render_activity(activity)
    view = ['logcraft', activity.trackable_type.to_s.underscore, activity.key].join('/')
    render partial: view,
           locals: { activity: activity },
           layout: 'logcraft/layout'
  rescue ActionView::MissingTemplate
    render partial: 'logcraft/default',
           locals: { activity: activity, expect_view: view },
           layout: 'logcraft/layout'
  end

  def logcraft_source_tag(activity)
    case activity.source[:channel]
    when 'api'     then logcraft_api_source_tag(activity)
    when 'admin'   then content_tag(:span, 'Admin', class: 'badge badge-success')
    when 'print'   then content_tag(:span, 'Print', class: 'badge badge-purple')
    when 'webhook' then content_tag(:span, 'Webhook', class: 'badge badge-warning')
    when 'worker'  then content_tag(:span, 'Worker', class: 'badge badge-pink')
    when 'ftp'     then content_tag(:span, 'FTP', class: 'badge badge-grey')
    when 'invoice' then content_tag(:span, 'Invoice', class: 'badge badge-primary')
    when 'web'     then logcraft_web_source_tag(activity)
    else                content_tag(:span, 'Unknown', class: 'badge')
    end
  end

  def logcraft_keyword(keyword, color = 'green')
    content_tag(:span, keyword, class: color)
  end

  def logcraft_api_source_tag(activity)
    return logcraft_api_v3_source_tag(activity) if activity.source[:oauth_app_id]

    os_string     = "#{activity.source[:os_type]} #{activity.source[:os_version]}"
    app_string    = activity.source[:app_version]
    device_string = activity.source[:device_model]
    ip_string     = activity.source[:ip]
    content_tag(:span, 'API',         class: 'badge badge-info') +
    content_tag(:span, os_string,     class: 'badge badge-info') +
    content_tag(:span, app_string,    class: 'badge badge-info') +
    content_tag(:span, device_string, class: 'badge badge-info') +
    content_tag(:span, ip_string,     class: 'badge badge-info')
  end

  def logcraft_api_v3_source_tag(activity)
    app = Doorkeeper::Application.find(activity.source[:oauth_app_id])
    os_string     = "#{activity.source[:os_type]} #{activity.source[:os_version]}"
    app_string    = activity.source[:app_version]
    device_string = activity.source[:device_model]
    ip_string     = activity.source[:ip]

    title = [
      "OS: #{os_string}",
      "App: #{app_string}",
      "Device: #{device_string}",
      "IP Address: #{ip_string}"
    ].join("\n")

    content_tag(:span, 'API',    class: 'badge badge-info') +
    content_tag(:span, app.name, class: 'badge badge-info', title: title)
  end

  def logcraft_web_source_tag(activity)
    os_string = "#{activity.source[:os_type]} #{activity.source[:os_version]}"
    ip_string = activity.source[:ip]
    content_tag(:span, 'Web',         class: 'badge badge-yellow') +
    content_tag(:span, os_string,     class: 'badge badge-yellow') +
    content_tag(:span, ip_string,     class: 'badge badge-yellow')
  end
end
