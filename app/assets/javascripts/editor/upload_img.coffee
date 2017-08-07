# upload images
# Get the template HTML and remove it from the doumenthe template HTML and remove it from the doument
previewNode = document.querySelector("#template")
previewNode.id = ""
previewTemplate = previewNode.parentNode.innerHTML
previewNode.parentNode.removeChild previewNode
upload_img = ""
upload_file = ""
@myDropzone = new Dropzone(document.body, # Make the whole body a dropzone
  url: $('#drawing').data('layersPath') # Set the url
  thumbnailWidth: null
  thumbnailHeight: null
  parallelUploads: 20
  maxFiles: 1
  maxFilesize: 6
  acceptedFiles: ".png,.jpg,.jpeg,.PNG,.JPG,.JPEG"
  dictInvalidFileType: "This file type is not supported."
  previewTemplate: previewTemplate
  autoQueue: true # Make sure the files aren't queued until manually added
  previewsContainer: "#previews" # Define the container to display the previews
  headers: 'X-CSRF-Token' : $('meta[name=csrf-token]').attr('content')
  clickable: ".fileinput-button" # Define the element that should be used as click trigger to select files.
)

@myDropzone.on "addedfile", (file) ->
  $('#previews').removeClass('hide')
  $('#previews .dz-error').hide()
  # Hookup the start button
  file.previewElement.querySelector(".start").onclick = ->
    myDropzone.enqueueFile file
    return

  console.log "addedfile", file
  return

@myDropzone.on "sending", (file) ->
  # Show the total progress bar when upload starts
  document.querySelector("#total-progress").style.opacity = "1"

  # And disable the start button
  file.previewElement.querySelector(".start").setAttribute "disabled", "disabled"
  $(".fileinput-button").attr('disabled', true)
  console.log 'files sending...'
  return

# Update the total progress bar
@myDropzone.on "totaluploadprogress", (progress) ->
  # document.querySelector("#total-progress .progress-bar").style.width = progress + "%"
  return

@myDropzone.on "uploadprogress", (file, progress) ->
  # console.log progress
  document.querySelector("#file_progress .progress-bar").style.width = progress + "%"
  console.log "uploadprogress"
  return

@myDropzone.on "thumbnail", (file, response) ->
  window.upload_file_thumb = response
  console.log 'thumbnail...'
  return

@myDropzone.on "success", (file, response) ->
  console.log 'files success...'
  window.upload_img = response.url
  window.upload_file = file
  window.upload_file_uuid = response.uuid
  $(".fileinput-button").addClass("hide")
  $(".image-ready").removeClass("hide")
  # console.log window.upload_file_uuid
  return

# Hide the total progress bar when nothing's uploading anymore
@myDropzone.on "complete", (progress) ->
  console.log 'files complete...'
  document.querySelector("#total-progress").style.opacity = "0"
  document.querySelector("#file_progress .progress-bar").style.width = progress + "%"
  # $(".fileinput-button").text("Next").attr("data-next", "ready").attr("data-type", "upload_img")
  return

# Cancel image upload

$('#upload_from_computer').on 'hidden.bs.modal', ->
  if window.upload_file_uuid?.length > 0
    path = $('#drawing').data('layersPath')
    url = path + '/' + window.upload_file_uuid

    $.ajax(
      url: url
      type: 'DELETE'
    ).done((response) =>
      window.myDropzone.removeFile(window.upload_file)
      window.upload_file_uuid = ''
      console.log 'Data Saved: ', response
      return
    ).fail((response) =>
      console.log 'Error: ', response.responseText
      return
    )
  else
    myDropzone.removeAllFiles(true)

  $('#previews').addClass('hide')
  $('.image-ready').addClass('hide')
  $('.fileinput-button').removeClass('hide').attr('disabled', false)
  return
