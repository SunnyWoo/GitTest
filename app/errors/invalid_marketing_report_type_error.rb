class InvalidMarketingReportTypeError < ServiceObjectError
  def message
    I18n.t('errors.service_object.invalid_marketing_report_type', type: caused_by)
  end
end
