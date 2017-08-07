@CPA.Actions.Flash =
  error: (body, title = 'Error') ->
    Gritter.error_msg(title, body)
