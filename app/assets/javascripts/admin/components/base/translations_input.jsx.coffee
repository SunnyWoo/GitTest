# @cjsx
@CPA.Base.TranslationsInput = React.createClass
  updateLocale: (locale) -> (e) ->
    value = _.clone(@props.value)
    value[locale] = e.target.value
    @props.onChange?(value: value)

  render: ->
    if @props.vertical
      @renderVertical()
    else
      @renderHorizontal()

  renderHorizontal: ->
    captions = for locale in _.keys(@props.value)
      <th>{locale}</th>

    inputs = for locale in _.keys(@props.value)
      if @props.multiline
        <td><textarea value={@props.value[locale]} onChange={@updateLocale(locale).bind(@)} /></td>
      else
        <td><input value={@props.value[locale]} onChange={@updateLocale(locale).bind(@)} /></td>

    <table className='table translations-input'>
      <thead>
        <tr>{captions}</tr>
      </thead>
      <tbody>
        <tr>{inputs}</tr>
      </tbody>
    </table>

  renderVertical: ->
    inputs = for locale in _.keys(@props.value)
      input = if @props.multiline
                <td><textarea value={@props.value[locale]} onChange={@updateLocale(locale).bind(@)} /></td>
              else
                <td><input value={@props.value[locale]} onChange={@updateLocale(locale).bind(@)} /></td>
      <label>
        {locale}
        {input}
      </label>

    <div className='translations-input-vertical'>{inputs}</div>
