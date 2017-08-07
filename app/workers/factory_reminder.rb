class FactoryReminder
  include Sidekiq::Worker

  def perform(batch_id, opts)
    opts = opts.stringify_keys
    batch_flow = BatchFlow.find batch_id
    batch_flow.send_mail(type: opts.fetch('type'))
  end
end
