class FactoryMailer < ApplicationMailer
  def file_uploaded(batch_flow_id, factory_id)
    @factory = Factory.find factory_id
    @batch_flow = @factory.batch_flows.find batch_flow_id

    receivers = @factory.contact_email.to_s.split(',')
    bcc = SiteSetting.by_key('BatchFlowInnerMailList').to_s.split(',')

    subject = I18n.t('subject',
      scope: 'print.batch_flow.notification',
      factory_name: @factory.name,
      number_with_source: @batch_flow.number_with_source
    )

    mail to: receivers, bcc: bcc, subject: subject
  end
end
