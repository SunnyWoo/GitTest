# @cjsx

@CPA.Common.AttachmentInput = React.createClass
  getDefaultProps: ->
    defaultImage: 'http://placehold.it/100x100'
    dropZone: 'self'
    type: 'POST'
    url: CPA.path('/attachments')
    name: 'file'

  propTypes:
    defaultImage: React.PropTypes.string.isRequired
    dropZone:     React.PropTypes.string.isRequired
    type:         React.PropTypes.string.isRequired
    url:          React.PropTypes.string.isRequired
    name:         React.PropTypes.string.isRequired
    value:        React.PropTypes.string
    onChange:     React.PropTypes.func
    onError:      React.PropTypes.func

  componentDidMount: ->
    $input = $(@refs.uploader.getDOMNode())
    $dropZone = switch @props.dropZone
                  when 'self' then $input
                  when 'document' then $(document)
    $input
      .fileupload(
        type:      @props.type
        url:       @props.url
        paramName: @props.name
        dropZone:  $dropZone
      )
      .on('fileuploaddone', @onUploadDone)
      .on('fileuploadfail', @onUploadFail)

  componentWillUnmount: ->
    $(@refs.uploader.getDOMNode()).fileupload('destroy')

  onUploadDone: (e, data) ->
    @props.onChange?(e, data)

  onUploadFail: (e, data) ->
    @props.onError?(e, data)

  render: ->
    <div className='file-input-container'>
      <img src={@props.value or @props.defaultImage} />
      <input type='file' ref='uploader' />
    </div>
