adjustModalMaxHeightAndPosition = ->
  $(".modal").each ->
    $(this).show()  if $(this).hasClass("in") is false # Need this to get modal dimensions
    contentHeight = $(window).height() - 81
    headerHeight = $(this).find(".modal-header").outerHeight() or 2
    footerHeight = $(this).find(".modal-footer").outerHeight() or 2
    $(this).find(".modal-content").css "max-height": contentHeight

    $(this).find(".modal-body").css "max-height": contentHeight - (headerHeight + footerHeight + 30), "overflow-y": 'auto'

    $(this).find(".modal-dialog").addClass("modal-dialog-center").css
      "margin-top": ->
        -($(this).outerHeight() / 2)
      "margin-left": ->
        -($(this).outerWidth() / 2)

    $(this).hide()  if $(this).hasClass("in") is false # Hide modal
    return

  return

$(window).resize(adjustModalMaxHeightAndPosition).trigger "resize"  if $(window).height() >= 320
