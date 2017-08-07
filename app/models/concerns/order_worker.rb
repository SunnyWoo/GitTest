module OrderWorker
  def sms_worker_collect
    sms_pay_notice_job_id = SmsWaitingForPayNoticeWorker.perform_in(30.seconds, id)
    create_activity(:create_sms_job, message: '加入簡訊付款資訊 通知至工作排程', job_id: sms_pay_notice_job_id)
    sms_job_id = PaymentDun.perform_at(order_payment_note_time(Time.zone.now), id)
    create_activity(:create_sms_job, message: '加入簡訊付款截止 通知至工作排程', job_id: sms_job_id)
    update(sms_job_id: sms_job_id, sms_pay_notice_job_id: sms_pay_notice_job_id)
  end

  # 依需求在48小時候的中午12點寄出，若48小時候已經超過12點，則順延到下一天中午
  def order_payment_note_time(time)
    if time.hour < 12
      (time + 2.days).at_noon
    else
      (time + 3.days).at_noon
    end
  end

  def enqueue_nuandao_order_shipping
    NuandaoOrderShippingWorker.perform_in(1.minute, id) if aasm_state_changed? && !aasm_state_was.nil? && payment == 'nuandao_b2b'
  end

  def enqueue_post_to_mailgun_mailing_list
    MailgunAddMailingListWorker.perform_async(billing_info_email, 'all')
    MailgunAddMailingListWorker.perform_async(billing_info_email, 'bought')
  end

  def enqueue_imposite_and_upload
    product_models = order_items.map(&:itemable).map(&:product).uniq
    product_models.each do |product|
      next unless product.auto_imposite?
      product.enqueue_imposite_and_upload
    end
  end

  # 訂單須在 24 小時內完成結帳，若超過 24 小時自動變更為無效的訂單
  # https://app.asana.com/0/9672537926113/105169920950177
  def enqueue_cancel_order
    return if delay_payment? || !pending?
    job_id = CancelOrderWorker.perform_in(1.day, id)
    update(cancel_order_job_id: job_id)
    create_activity(:create_cancel_order_job, message: '加入取消訂單至工作排程', job_id: job_id)
  end
end
