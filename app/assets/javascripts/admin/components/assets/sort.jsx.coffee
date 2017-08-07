# @cjsx

@CPA.Assets.Sort = React.createClass
  propTypes:
    onChange: React.PropTypes.func.isRequired

  getInitialState: ->
    sortCollection: [
      { value: '',         label: 'Select sort type' }
      { value: 'downloads', label: 'Downloads Count' }
      { value: 'begins',   label: 'Begins at' }
      { value: 'ends',     label: 'Ends at' }
    ]
    sortType: ''

  setValue: (e) ->
    @setState(sortType: e.target.value)

  onSort: (e) ->
    @props.onChange?(@state.sortType)

  render: ->
    <div>
      <CPA.Base.SelectInput value={@state.sortType}
                            onChange={@setValue}
                            collection={@state.sortCollection} />
      <button className="btn btn-md" onClick={@onSort}>
        Sort
      </button>
    </div>
