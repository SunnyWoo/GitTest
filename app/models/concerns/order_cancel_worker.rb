module OrderCancelWorker
  extend ActiveSupport::Concern

  included do
    before_save :cancel_worker_collect, if: :aasm_state_changed_to_canceled_or_paid?
  end

  # order after paid or cancel 會執行
  def cancel_worker_collect
    cancel_payment_dun
    cancel_payment_notice
    cancel_order_worker
  end

  def cancel_payment_dun
    cancel_work('sms', sms_job_id) if sms_job_id.present?
  end

  def cancel_payment_notice
    cancel_work('sms_pay_notice', sms_pay_notice_job_id) if sms_pay_notice_job_id.present?
  end

  def cancel_order_worker
    cancel_work('cancel_order', cancel_order_job_id) if cancel_order_job_id.present?
  end

  private

  def cancel_work(key, job_id)
    attr_name = "#{key}_job_id"
    return unless send(attr_name)
    job = Sidekiq::ScheduledSet.new.find_job(job_id) ||
          Sidekiq::RetrySet.new.find_job(job_id) ||
          Sidekiq::DeadSet.new.find_job(job_id)
    if job.try(:delete)
      create_activity("cancel_#{key}_job")
      send(attr_name + '=', nil)
    else
      create_activity("#{key}_job_missing")
    end
  end

  # aasm_state change from wating_for_payment to canceled or paid
  def aasm_state_changed_to_canceled_or_paid?
    aasm_state_changed? && %w(canceled paid).include?(aasm_state_change.last.to_s)
  end
end
