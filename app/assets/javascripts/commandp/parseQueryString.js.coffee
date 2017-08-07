window.Commandp.parseQueryString = ->
  str = window.location.search
  objURL = {}
  str.replace new RegExp("([^?=&]+)(=([^&]*))?", "g"), ($0, $1, $2, $3) ->
    objURL[$1] = $3
    return

  objURL