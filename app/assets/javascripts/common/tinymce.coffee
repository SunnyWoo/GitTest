#= require tinymce-jquery
jQuery ($) ->
  $(document).on 'page:change',  ->
    tinyMCE.init
      selector: 'textarea.tinymce'
      theme: "modern"
      plugins: [
        "advlist autolink lists link image charmap print preview hr anchor pagebreak"
        "searchreplace wordcount visualblocks visualchars code fullscreen"
        "insertdatetime media nonbreaking save table contextmenu directionality"
        "emoticons template paste textcolor colorpicker textpattern"
        "uploadimage"
      ]
      toolbar1: "insertfile undo redo | styleselect | bold italic | alignleft aligncenter alignright alignjustify | bullist numlist outdent indent"
      toolbar2: "forecolor backcolor emoticons | link image uploadimage | preview"
      image_advtab: true
      uploadimage_form_url: '/en/admin/tinymce_assets'
      convert_urls: false