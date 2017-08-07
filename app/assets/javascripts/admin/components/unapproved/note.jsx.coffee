# Public: Note Component
#
# Properties:
#   orderID   - Order id for note
#   createUrl - Api url for creating a note
#   notes     - All current note lists
#
# End

# @cjsx

@CPA.Unapproved.Note = React.createClass
  propTypes:
    orderID: React.PropTypes.string
    createUrl: React.PropTypes.string
    notes: React.PropTypes.array

  getInitialState: ->
    notes: @props.notes
    createNote: ''

  render: ->
    buttons = [
      {
        type: 'primary'
        text: 'Submit'
        handler: @handleExternalHide
      }
    ]
    notes = @state.notes.map (note) =>
      <CPA.Unapproved.NoteRow orderID={@props.orderID} note={note} key={@props.orderID+"_"+note.id} />
    
    <div>
      <table className="show-notes table table-striped table-bordered">
        <thead>
          <tr>
            <th>Date</th>
            <th>Message</th>
            <th>Noted By</th>
            <th>
              <button type="button" className="btn btn-primary btn-sm btn-block" onClick={@handleShowModal}>Note</button>
            </th>
          </tr>
        </thead>
        <tbody>
          {notes}
        </tbody>
      </table>
      <CPA.Base.Modal key={@props.orderID}
                      ref="modal"
                      show={false}
                      header="Create Note"
                      buttons={buttons}
                      onClick={@submitNote}>
        <div>Note</div>
        <textarea className="text optional form-control"
                  cols="5"
                  name="note[message]"
                  rows="10"
                  value={@state.createNote}
                  onChange={@updateNote}></textarea>
      </CPA.Base.Modal>
    </div>

  handleShowModal: ->
    @setState(createNote: '')
    @refs.modal.show()

  handleExternalHide: ->
    @refs.modal.hide()

  submitNote: ->
    ajax = $.ajax
      url: @props.createUrl
      type: 'POST'
      dataType: 'json'
      data:
        note:
          message: @state.createNote

    ajax.done (response) =>
      newNote = @state.notes
      newNote.push(response.note)
      @setState(notes: newNote)
      @refs.modal.hide()

  updateNote: (e) ->
    @setState(createNote: e.target.value)

