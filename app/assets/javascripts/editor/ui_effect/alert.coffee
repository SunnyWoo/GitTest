$('.header a').on 'click', ->
  window.onbeforeunload = (e) ->
    message = "Your work may not store, are you sure to leave?"
    console.log e.target
    e = e or window.event
    # For IE and Firefox
    e.returnValue = message  if e
    # For Safari
    message
  return

$('#preview .btn').on 'click', ->
  window.onbeforeunload = null;
  return