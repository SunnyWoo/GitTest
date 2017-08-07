module Admin::NewsletterHelper
  def render_report(newsletter)
    text = I18n.t("newsletter.state.#{newsletter.state}")
    if newsletter.mailgun_campaign && newsletter.mailgun_campaign.report.present?
      report = newsletter.mailgun_campaign.report
      text += "<br>(#{report.clicked_count}/#{report.opened_count}/#{report.delivered_count}/#{report.submitted_count})"
    end
    text.html_safe
  end

  def render_user_group(newsletter)
    if newsletter.filter.present? && newsletter.filter.is_a?(Hash)
      Newsletter.user_group[newsletter.filter['user_group'].to_sym]
    elsif newsletter.filter.is_a?(Array)
      newsletter.filter.join(', ')
    else
      ''
    end
  end
end
