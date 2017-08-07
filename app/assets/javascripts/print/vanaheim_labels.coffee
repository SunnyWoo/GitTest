#= require react
#= require react_ujs
#= require flux
#= require eventEmitter
#= require plugins/lodash.min
# @cjsx

dispatcher = new Flux.Dispatcher()
dispatcher.register (payload) ->
  console.log 'dispached:', payload

class LabelStoreClass extends EventEmitter
  nextId: 0
  availableLocales: ['zh-TW', 'zh-CN', 'en', 'ja']
  labels: []

  constructor: ->
    dispatcher.register (payload) =>
      switch payload.action
        when 'loadLabels'  then @load(payload.labels)
        when 'updateLabel' then @update(payload.id, _.omit(payload, 'id'))
        when 'addLabel'    then @add()
        when 'removeLabel' then @remove(payload.id)

  load: (labels) ->
    @add(label) for label in labels

  add: (label = @defaultLabel()) ->
    label.id = @nextId++
    @labels.push(label)
    @emitChange()

  remove: (id) ->
    _.remove(@labels, id: id)
    @emitChange()

  update: (id, payload) ->
    label = _.find(@labels, id: id)
    _.assign(label, payload)
    @emitChange()

  defaultLabel: ->
    label = name: '', contents: []
    label.contents.push(locale: locale, content: '') for locale in @availableLocales
    label

  emitChange: -> @emit('change')

LabelStore = new LabelStoreClass

class App extends React.Component
  componentDidMount: ->
    dispatcher.dispatch(action: 'loadLabels', labels: @props.labels)

  render: ->
    <div>
      <p>Available variables: <code>%&#123;order_number}</code>, <code>%&#123;product_name}</code></p>
      <List />
    </div>

class List extends React.Component
  constructor: ->
    @state = labels: LabelStore.labels

  componentDidMount: ->
    LabelStore.on('change', @updateStateFromStore)

  componentWillUnmount: ->
    LabelStore.off('change', @updateStateFromStore)

  updateStateFromStore: =>
    @setState(labels: LabelStore.labels)

  add: (e) ->
    e.preventDefault()
    dispatcher.dispatch(action: 'addLabel')

  render: ->
    labels = @state.labels
    <table>
      <tbody>
        <tr>
          <th>Label name</th>
          <th>Contents</th>
          <th></th>
        </tr>
        { labels.map (label, i) ->
          <Label key={i} label={label} />
        }
        <tr>
          <td colSpan='3'><button className='btn btn-default' onClick={@add}>Add</button></td>
        </tr>
      </tbody>
    </table>

class Label extends React.Component
  updateName: (e) =>
    dispatcher.dispatch(action: 'updateLabel', id: @props.label.id, name: e.target.value)

  updateContents: (e) =>
    dispatcher.dispatch(action: 'updateLabel', id: @props.label.id, contents: e.value)

  remove: (e) =>
    e.preventDefault()
    dispatcher.dispatch(action: 'removeLabel', id: @props.label.id)

  render: ->
    <tr>
      <td><input name='imposition[labels][][name]' className='form-control'
                 value={@props.label.name} onChange={@updateName} /></td>
      <td><LabelContents contents={@props.label.contents} onChange={@updateContents} /></td>
      <td><button className='btn btn-default' onClick={@remove}>Remove</button></td>
    </tr>

class LabelContents extends React.Component
  updateContent: (content) => (e) =>
    content.content = e.target.value
    @props.onChange(value: @props.contents)

  render: ->
    <div className='block-grid-xs-5'>
      { @props.contents.map (content) =>
        <div key={content.locale} className='block-grid-item'>
          <div>{content.locale}</div>
          <input name='imposition[labels][][contents][][locale]' type='hidden' value={content.locale} />
          <input name='imposition[labels][][contents][][content]' className='form-control'
                 value={content.content} onChange={@updateContent(content)} />
        </div>
      }
    </div>

@VanaheimLabelsApp = App
