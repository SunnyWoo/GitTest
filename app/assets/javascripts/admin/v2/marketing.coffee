$(document).on 'page:change',  ->
  if $('#marketing_sms_send_type').length > 0
    $('#marketing_sms_send_type').on 'change', ->
      $this = $(this)
      if $this.val() == 'test'
        $this.nextAll('.test_phone').show()
      else
        $this.nextAll('.test_phone').hide()

