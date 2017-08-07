$.jsonRequest = (type, url, data) ->
  $.ajax(
    type: type
    url: url
    data: JSON.stringify(data) if data
    contentType: 'application/json'
    dataType: 'json'
  )

$.jsonGET = (url, data) -> $.jsonRequest('GET', url, data)

$.jsonPOST = (url, data) -> $.jsonRequest('POST', url, data)

$.jsonPATCH = (url, data) -> $.jsonRequest('PATCH', url, data)

$.jsonPUT = (url, data) -> $.jsonRequest('PUT', url, data)

$.jsonDELETE = (url, data) -> $.jsonRequest('DELETE', url, data)
