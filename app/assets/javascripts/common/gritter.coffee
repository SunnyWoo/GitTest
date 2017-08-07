#= require print/jquery.gritter.min

@Gritter =
  error_msg: (title, text = null) ->
    param =
      title: title
      class_name: 'gritter-error'
      sticky: true
    param.text = text if text
    $.gritter.add param

  # class_name :
  #  for color:  gritter-light gritter-info gritter-success gritter-warning
  #  is_center:  gritter-center
  regular_msg: (title, text = '', image = null, sticky = false, time = '', class_name = 'gritter-light') ->
    param =
      position: 'bottom-left'
      title: title
      text: text
      sticky: sticky
      time: time
      class_name: class_name
    param.image if image != null
    $.gritter.add param

  remove_all: ->
    $.gritter.removeAll()