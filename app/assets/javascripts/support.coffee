$ ->
  $(document).on 'change', '.form #zendesk_form_attachments', ->
    files = $(this).prop("files")
    $('#filelist').html('')
    $.each files, (i) ->
      tag = "image_#{i}"
      f_html = "<p><img id=\"#{tag}\" src=''>#{this.name}</p>"
      $('#filelist').append(f_html)
      reader = new FileReader()
      reader.onload = (e) ->
        $("##{tag}").attr('src', e.target.result);
      reader.readAsDataURL(this);

  $(document).on 'submit', '#new_zendesk_form', ->
    $(this).find('input[type=submit]').attr('disabled', 'disabled')
    $.fancybox.showLoading()
