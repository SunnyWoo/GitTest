#@cjsx

@CPA.Unapproved.NoteRow = React.createClass
  getInitialState: ->
    note: @props.note
    createNote: @props.note.message

  render: ->
    buttons = [
      {
        type: 'primary'
        text: 'Update'
        handler: @handleExternalHide
      }
    ]
    <tr>
      <td>{new Date(@props.note.created_at).toLocaleString()}</td>
      <td className="msg">{@state.createNote}</td>
      <td>{@props.note.user_email}</td>
      <td>
        {@checkAvailabletoEdit()}
        <CPA.Base.Modal key={@props.orderID + "_" + @props.note.id}
                        ref="modal"
                        show={false}
                        header={"Note > " + @props.note.id}
                        buttons={buttons}
                        onClick={@submitNote}>
          <div>Note</div>
          <textarea className="text optional form-control"
                    cols="5"
                    name="note[message]"
                    rows="10"
                    defaultValue={@props.note.message}
                    onBlur={@updateNote}></textarea>
        </CPA.Base.Modal>
      </td>
    </tr>

  checkAvailabletoEdit: ->
    if @props.note.links
      <button type="button" className="btn btn-sm btn-block" onClick={@handleShowModal}>Edit</button>
    else
      ""

  handleShowModal: ->
    @refs.modal.show()

  handleExternalHide: ->
    @refs.modal.hide()

  submitNote: ->
    ajax = $.ajax
      url: @props.note.links.update
      type: 'PATCH'
      dataType: 'json'
      data:
        note:
          id: @props.note.id
          message: @state.createNote

    ajax.done (response) =>
      @setState(note: response.note)
      @refs.modal.hide()

  updateNote: (e) ->
    @setState(createNote: e.target.value)